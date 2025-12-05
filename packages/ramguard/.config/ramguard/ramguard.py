#!/usr/bin/env python3
"""
RAM Guardian - Memory monitoring daemon for Vibearchy
Monitors system RAM, detects Electron apps, applies memory limits,
and sends notifications via SwayNC.
"""

import json
import os
import signal
import socket
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

try:
    import psutil
except ImportError:
    print("Error: psutil not installed. Run: sudo pacman -S python-psutil", file=sys.stderr)
    sys.exit(1)

try:
    import tomllib
except ImportError:
    import tomli as tomllib

# === Configuration ===

CONFIG_DIR = Path.home() / ".config" / "ramguard"
CONFIG_FILE = CONFIG_DIR / "ramguard.toml"
SOCKET_PATH = Path("/tmp/ramguard.sock")

ELECTRON_SIGNATURES = [
    "electron",
    "--type=renderer",
    "--type=gpu-process",
    "--type=utility",
    "chrome-sandbox",
]

KNOWN_ELECTRON_APPS = {
    "code": "VS Code",
    "discord": "Discord",
    "slack": "Slack",
    "spotify": "Spotify",
    "obsidian": "Obsidian",
    "signal-desktop": "Signal",
    "teams": "Teams",
    "notion": "Notion",
    "bitwarden": "Bitwarden",
    "1password": "1Password",
    "figma": "Figma",
    "postman": "Postman",
    "insomnia": "Insomnia",
    "zettlr": "Zettlr",
    "logseq": "Logseq",
}

DEFAULT_CONFIG = {
    "thresholds": {
        "warning_percent": 80,
        "critical_percent": 90,
        "check_interval_seconds": 5,
    },
    "electron": {
        "enabled": True,
        "max_memory_mb": 2048,
        "auto_limit": True,
        "notify_on_detect": True,
    },
    "notifications": {
        "enabled": True,
        "min_interval_seconds": 60,
        "swaync_actions": True,
    },
    "whitelist": {
        "processes": ["firefox", "zen"],
    },
    "electron_apps": {},
}


@dataclass
class ProcessInfo:
    pid: int
    name: str
    cmdline: str
    memory_mb: float
    memory_percent: float
    is_electron: bool
    electron_app_name: Optional[str] = None


@dataclass
class SystemState:
    memory_percent: float
    memory_used_gb: float
    memory_total_gb: float
    top_processes: list[ProcessInfo] = field(default_factory=list)
    electron_processes: list[ProcessInfo] = field(default_factory=list)
    alert_level: str = "normal"  # normal, warning, critical


class RamGuard:
    def __init__(self):
        self.config = self._load_config()
        self.running = True
        self.state = SystemState(0, 0, 0)
        self.last_notification_time: dict[str, float] = {}
        self.known_electron_pids: set[int] = set()
        self.limited_pids: dict[int, str] = {}  # pid -> scope name
        self.socket_server: Optional[socket.socket] = None

    def _load_config(self) -> dict:
        config = DEFAULT_CONFIG.copy()
        if CONFIG_FILE.exists():
            try:
                with open(CONFIG_FILE, "rb") as f:
                    user_config = tomllib.load(f)
                    self._deep_merge(config, user_config)
            except Exception as e:
                self._log(f"Error loading config: {e}")
        return config

    def _deep_merge(self, base: dict, override: dict) -> None:
        for key, value in override.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                self._deep_merge(base[key], value)
            else:
                base[key] = value

    def _log(self, msg: str) -> None:
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {msg}", file=sys.stderr)

    def _notify(
        self,
        title: str,
        body: str,
        urgency: str = "normal",
        actions: Optional[list[tuple[str, str]]] = None,
        category: str = "ramguard",
    ) -> None:
        if not self.config["notifications"]["enabled"]:
            return

        # Rate limiting
        now = time.time()
        min_interval = self.config["notifications"]["min_interval_seconds"]
        key = f"{category}:{title}"
        if key in self.last_notification_time:
            if now - self.last_notification_time[key] < min_interval:
                return
        self.last_notification_time[key] = now

        cmd = [
            "notify-send",
            "-u", urgency,
            "-a", "RAM Guardian",
            "-c", category,
        ]

        # Add action buttons if SwayNC actions enabled
        if actions and self.config["notifications"]["swaync_actions"]:
            for action_id, action_label in actions:
                cmd.extend(["-A", f"{action_id}={action_label}"])

        cmd.extend([title, body])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            # Handle action response
            if result.stdout.strip() and actions:
                self._handle_notification_action(result.stdout.strip(), category)
        except Exception as e:
            self._log(f"Notification error: {e}")

    def _handle_notification_action(self, action: str, category: str) -> None:
        """Handle notification button clicks."""
        if action == "open_menu":
            subprocess.Popen(["rofi-ramguard-menu"])
        elif action == "kill_top":
            if self.state.top_processes:
                top = self.state.top_processes[0]
                self._kill_process(top.pid)
        elif action.startswith("set_limit:"):
            pid = int(action.split(":")[1])
            subprocess.Popen(["rofi-ramguard-menu", "--set-limit", str(pid)])
        elif action.startswith("whitelist:"):
            name = action.split(":")[1]
            self._add_to_whitelist(name)

    def _is_whitelisted(self, name: str) -> bool:
        return name.lower() in [p.lower() for p in self.config["whitelist"]["processes"]]

    def _add_to_whitelist(self, name: str) -> None:
        if name not in self.config["whitelist"]["processes"]:
            self.config["whitelist"]["processes"].append(name)
            self._save_config()
            self._notify("Whitelisted", f"{name} added to whitelist", "low")

    def _save_config(self) -> None:
        # Convert config to TOML and save
        import toml
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        with open(CONFIG_FILE, "w") as f:
            toml.dump(self.config, f)

    def _is_electron_process(self, proc: psutil.Process) -> tuple[bool, Optional[str]]:
        """Check if process is Electron-based and identify the app."""
        try:
            cmdline = " ".join(proc.cmdline()).lower()
            name = proc.name().lower()

            # Check known apps first
            for app_key, app_name in KNOWN_ELECTRON_APPS.items():
                if app_key in name or app_key in cmdline:
                    return True, app_name

            # Check signatures
            if any(sig in cmdline for sig in ELECTRON_SIGNATURES):
                return True, None

            return False, None
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            return False, None

    def _get_process_info(self, proc: psutil.Process) -> Optional[ProcessInfo]:
        """Get process info with memory stats."""
        try:
            mem_info = proc.memory_info()
            cmdline = " ".join(proc.cmdline())
            is_electron, app_name = self._is_electron_process(proc)

            return ProcessInfo(
                pid=proc.pid,
                name=proc.name(),
                cmdline=cmdline[:200],
                memory_mb=mem_info.rss / (1024 * 1024),
                memory_percent=proc.memory_percent(),
                is_electron=is_electron,
                electron_app_name=app_name,
            )
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            return None

    def _apply_memory_limit(self, proc_info: ProcessInfo) -> bool:
        """Apply cgroups memory limit to process."""
        if not self.config["electron"]["auto_limit"]:
            return False

        if proc_info.pid in self.limited_pids:
            return True  # Already limited

        # Get app-specific limit or default
        app_name = (proc_info.electron_app_name or proc_info.name).lower()
        limit_mb = self.config["electron_apps"].get(
            app_name, self.config["electron"]["max_memory_mb"]
        )

        scope_name = f"ramguard-{proc_info.pid}"
        try:
            # Use systemd-run to apply memory limit
            subprocess.run(
                [
                    "systemd-run",
                    "--user",
                    "--scope",
                    f"--unit={scope_name}",
                    "-p", f"MemoryMax={limit_mb}M",
                    "-p", "MemorySwapMax=0",
                    "--",
                    "true",  # dummy command, we're attaching existing process
                ],
                check=True,
                capture_output=True,
                timeout=5,
            )

            # Actually move the process to the scope
            # This requires the process to be running under our scope
            # Alternative: use cgroups directly
            cgroup_path = Path(f"/sys/fs/cgroup/user.slice/user-{os.getuid()}.slice")
            if cgroup_path.exists():
                scope_path = cgroup_path / f"{scope_name}.scope"
                if scope_path.exists():
                    with open(scope_path / "cgroup.procs", "w") as f:
                        f.write(str(proc_info.pid))

            self.limited_pids[proc_info.pid] = scope_name
            self._log(f"Applied {limit_mb}MB limit to {proc_info.name} (PID {proc_info.pid})")
            return True

        except subprocess.CalledProcessError as e:
            self._log(f"Failed to apply limit: {e}")
            return False
        except Exception as e:
            self._log(f"Error applying memory limit: {e}")
            return False

    def _kill_process(self, pid: int) -> bool:
        """Kill a process by PID."""
        try:
            proc = psutil.Process(pid)
            proc.terminate()
            proc.wait(timeout=3)
            self._notify("Process Killed", f"Terminated {proc.name()} (PID {pid})", "normal")
            return True
        except psutil.NoSuchProcess:
            return True
        except psutil.TimeoutExpired:
            try:
                proc.kill()
                return True
            except Exception:
                return False
        except Exception as e:
            self._log(f"Error killing process: {e}")
            return False

    def _poll_memory(self) -> None:
        """Poll system and process memory."""
        mem = psutil.virtual_memory()

        self.state.memory_percent = mem.percent
        self.state.memory_used_gb = mem.used / (1024**3)
        self.state.memory_total_gb = mem.total / (1024**3)

        # Determine alert level
        warning = self.config["thresholds"]["warning_percent"]
        critical = self.config["thresholds"]["critical_percent"]

        if mem.percent >= critical:
            self.state.alert_level = "critical"
        elif mem.percent >= warning:
            self.state.alert_level = "warning"
        else:
            self.state.alert_level = "normal"

        # Get top processes by memory
        processes = []
        electron_procs = []

        for proc in psutil.process_iter(["pid", "name"]):
            info = self._get_process_info(proc)
            if info and info.memory_mb > 50:  # Ignore tiny processes
                if not self._is_whitelisted(info.name):
                    processes.append(info)
                    if info.is_electron:
                        electron_procs.append(info)

        # Sort by memory usage
        processes.sort(key=lambda p: p.memory_mb, reverse=True)
        electron_procs.sort(key=lambda p: p.memory_mb, reverse=True)

        self.state.top_processes = processes[:20]
        self.state.electron_processes = electron_procs

    def _check_and_notify(self) -> None:
        """Check thresholds and send notifications."""
        state = self.state

        # System memory alerts
        if state.alert_level == "critical":
            top = state.top_processes[0] if state.top_processes else None
            top_msg = f" - {top.name} using {top.memory_mb:.0f}MB" if top else ""
            self._notify(
                "󰀦 RAM Critical!",
                f"RAM at {state.memory_percent:.0f}%{top_msg}\nConsider closing apps",
                urgency="critical",
                actions=[("open_menu", "Open Menu"), ("kill_top", "Kill Top")],
                category="ramguard-alert",
            )
        elif state.alert_level == "warning":
            top = state.top_processes[0] if state.top_processes else None
            top_msg = f" - {top.name} using {top.memory_mb:.0f}MB" if top else ""
            self._notify(
                "󰍛 RAM Warning",
                f"RAM at {state.memory_percent:.0f}%{top_msg}",
                urgency="normal",
                actions=[("open_menu", "Open Menu")],
                category="ramguard-alert",
            )

        # Electron app detection and limiting
        if self.config["electron"]["enabled"]:
            for proc in state.electron_processes:
                if proc.pid not in self.known_electron_pids:
                    self.known_electron_pids.add(proc.pid)
                    app_name = proc.electron_app_name or proc.name

                    if self.config["electron"]["notify_on_detect"]:
                        self._notify(
                            "󰘔 Electron App Detected",
                            f"{app_name} ({proc.memory_mb:.0f}MB)",
                            urgency="normal",
                            actions=[
                                (f"set_limit:{proc.pid}", "Set Limit"),
                                (f"whitelist:{proc.name}", "Whitelist"),
                            ],
                            category="ramguard-electron",
                        )

                    # Apply memory limit
                    if self.config["electron"]["auto_limit"]:
                        max_mem = self.config["electron"]["max_memory_mb"]
                        if proc.memory_mb > max_mem * 0.8:  # If using >80% of limit
                            if self._apply_memory_limit(proc):
                                self._notify(
                                    "󰄰 Memory Limit Applied",
                                    f"{app_name}: {max_mem}MB limit",
                                    urgency="low",
                                    actions=[("open_menu", "Configure")],
                                    category="ramguard-limit",
                                )

    def _get_status_json(self) -> str:
        """Get current status as JSON for Waybar."""
        state = self.state
        top = state.top_processes[0] if state.top_processes else None

        status = {
            "memory_percent": round(state.memory_percent, 1),
            "memory_used_gb": round(state.memory_used_gb, 2),
            "memory_total_gb": round(state.memory_total_gb, 2),
            "alert_level": state.alert_level,
            "top_process": top.name if top else None,
            "top_memory_mb": round(top.memory_mb, 0) if top else None,
            "electron_count": len(state.electron_processes),
            "limited_count": len(self.limited_pids),
        }
        return json.dumps(status)

    def _start_socket_server(self) -> None:
        """Start Unix socket server for IPC."""
        if SOCKET_PATH.exists():
            SOCKET_PATH.unlink()

        self.socket_server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.socket_server.bind(str(SOCKET_PATH))
        self.socket_server.listen(5)
        self.socket_server.settimeout(1.0)

        def handle_clients():
            while self.running:
                try:
                    conn, _ = self.socket_server.accept()
                    data = conn.recv(1024).decode().strip()

                    if data == "status":
                        response = self._get_status_json()
                    elif data == "processes":
                        response = json.dumps([
                            {
                                "pid": p.pid,
                                "name": p.name,
                                "memory_mb": round(p.memory_mb, 1),
                                "is_electron": p.is_electron,
                                "app_name": p.electron_app_name,
                            }
                            for p in self.state.top_processes
                        ])
                    elif data.startswith("kill:"):
                        pid = int(data.split(":")[1])
                        success = self._kill_process(pid)
                        response = json.dumps({"success": success})
                    elif data.startswith("limit:"):
                        parts = data.split(":")
                        pid, limit_mb = int(parts[1]), int(parts[2])
                        proc = next(
                            (p for p in self.state.top_processes if p.pid == pid),
                            None
                        )
                        if proc:
                            self.config["electron_apps"][proc.name.lower()] = limit_mb
                            self._save_config()
                            response = json.dumps({"success": True})
                        else:
                            response = json.dumps({"success": False})
                    else:
                        response = json.dumps({"error": "unknown command"})

                    conn.sendall(response.encode())
                    conn.close()
                except socket.timeout:
                    continue
                except Exception as e:
                    self._log(f"Socket error: {e}")

        thread = threading.Thread(target=handle_clients, daemon=True)
        thread.start()

    def _cleanup(self) -> None:
        """Cleanup on shutdown."""
        if self.socket_server:
            self.socket_server.close()
        if SOCKET_PATH.exists():
            SOCKET_PATH.unlink()

    def run(self) -> None:
        """Main daemon loop."""
        self._log("RAM Guardian starting...")

        # Setup signal handlers
        def handle_signal(signum, frame):
            self._log("Shutting down...")
            self.running = False

        signal.signal(signal.SIGTERM, handle_signal)
        signal.signal(signal.SIGINT, handle_signal)

        # Start socket server
        self._start_socket_server()

        interval = self.config["thresholds"]["check_interval_seconds"]

        try:
            while self.running:
                self._poll_memory()
                self._check_and_notify()
                time.sleep(interval)
        finally:
            self._cleanup()
            self._log("RAM Guardian stopped.")


def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "status":
            # Query daemon for status
            try:
                sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                sock.connect(str(SOCKET_PATH))
                sock.sendall(b"status")
                response = sock.recv(4096).decode()
                print(response)
                sock.close()
            except Exception as e:
                print(json.dumps({"error": str(e), "running": False}))
            return
        elif cmd == "processes":
            try:
                sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                sock.connect(str(SOCKET_PATH))
                sock.sendall(b"processes")
                response = sock.recv(65536).decode()
                print(response)
                sock.close()
            except Exception as e:
                print(json.dumps({"error": str(e)}))
            return

    # Run daemon
    guard = RamGuard()
    guard.run()


if __name__ == "__main__":
    main()
