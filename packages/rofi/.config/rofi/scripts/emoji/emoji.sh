#!/bin/bash
#
# Vibearchy Emoji Picker
# Quick emoji selection with search and recent history
#

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../lib/rofi-common.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

THEME="$SCRIPT_DIR/emoji.rasi"
[[ ! -f "$THEME" ]] && THEME="$ROFI_THEME"

# Data files
EMOJI_FILE="$SCRIPT_DIR/emojis.txt"
RECENT_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/vibearchy/recent-emojis.txt"

# Ensure data directory exists
mkdir -p "$(dirname "$RECENT_FILE")"

# Max recent emojis to track
MAX_RECENT=20

# ═══════════════════════════════════════════════════════════════════════════════
# EMOJI DATA
# ═══════════════════════════════════════════════════════════════════════════════

# Create emoji file if it doesn't exist
create_emoji_file() {
    [[ -f "$EMOJI_FILE" ]] && return

    cat > "$EMOJI_FILE" << 'EMOJIS'
😀 grinning face happy smile
😃 grinning face big eyes happy
😄 grinning face smiling eyes happy
😁 beaming face smiling eyes grin
😆 grinning squinting face laugh
😅 grinning face sweat awkward
🤣 rolling floor laughing lol rofl
😂 face tears joy crying laugh lol
🙂 slightly smiling face
😊 smiling face smiling eyes blush
😇 smiling face halo angel innocent
🥰 smiling face hearts love
😍 smiling face heart eyes love
🤩 star struck excited amazing
😘 face blowing kiss love
😗 kissing face
😚 kissing face closed eyes
😙 kissing face smiling eyes
🥲 smiling face tear happy sad
😋 face savoring food yummy delicious
😛 face tongue out playful
😜 winking face tongue crazy
🤪 zany face crazy wild
😝 squinting face tongue playful
🤑 money mouth face rich dollar
🤗 hugging face hug love
🤭 face hand over mouth oops giggle
🤫 shushing face quiet secret
🤔 thinking face hmm wondering
🤐 zipper mouth face quiet secret
🤨 face raised eyebrow skeptical
😐 neutral face meh
😑 expressionless face blank
😶 face without mouth silent
😏 smirking face smug
😒 unamused face annoyed
🙄 rolling eyes annoyed whatever
😬 grimacing face awkward cringe
😮‍💨 face exhaling sigh relief
🤥 lying face pinocchio
😌 relieved face calm peaceful
😔 pensive face sad thoughtful
😪 sleepy face tired
🤤 drooling face yummy want
😴 sleeping face zzz tired
😷 face medical mask sick covid
🤒 face thermometer sick fever
🤕 face bandage injured hurt
🤢 nauseated face sick gross
🤮 vomiting face sick gross
🤧 sneezing face sick cold
🥵 hot face sweating heat
🥶 cold face freezing ice
🥴 woozy face drunk dizzy
😵 face crossed eyes dizzy
😵‍💫 face spiral eyes dizzy confused
🤯 exploding head mind blown wow
🤠 cowboy hat face yeehaw
🥳 partying face celebration birthday
🥸 disguised face incognito
😎 smiling face sunglasses cool
🤓 nerd face glasses geek
🧐 face monocle curious inspect
😕 confused face unsure
😟 worried face anxious concern
🙁 slightly frowning face sad
😮 face open mouth surprised wow
😯 hushed face surprised
😲 astonished face shocked wow
😳 flushed face embarrassed
🥺 pleading face puppy eyes please
😦 frowning face open mouth
😧 anguished face distressed
😨 fearful face scared afraid
😰 anxious face sweat nervous
😥 sad but relieved face
😢 crying face tear sad
😭 loudly crying face sob tears
😱 face screaming fear scared
😖 confounded face frustrated
😣 persevering face struggling
😞 disappointed face sad
😓 downcast face sweat sad
😩 weary face tired exhausted
😫 tired face exhausted
🥱 yawning face sleepy bored
😤 face steam nose angry huffing
😡 pouting face angry mad
😠 angry face mad
🤬 face symbols mouth cursing swear
😈 smiling face horns devil
👿 angry face horns devil
💀 skull death dead
☠️ skull crossbones death danger
💩 pile poo poop
🤡 clown face
👹 ogre monster
👺 goblin monster
👻 ghost boo spooky
👽 alien ufo extraterrestrial
👾 alien monster space invader
🤖 robot face machine
😺 grinning cat happy
😸 grinning cat smiling eyes
😹 cat tears joy laughing
😻 smiling cat heart eyes love
😼 cat wry smile smirk
😽 kissing cat love
🙀 weary cat shocked
😿 crying cat sad
😾 pouting cat angry
🙈 see no evil monkey
🙉 hear no evil monkey
🙊 speak no evil monkey
💋 kiss mark lips
💌 love letter heart envelope
💘 heart arrow cupid love
💝 heart ribbon gift love
💖 sparkling heart love
💗 growing heart love
💓 beating heart love
💞 revolving hearts love
💕 two hearts love
💟 heart decoration love
❣️ heart exclamation love
💔 broken heart sad love
❤️‍🔥 heart fire passion love
❤️‍🩹 mending heart healing love
❤️ red heart love
🧡 orange heart love
💛 yellow heart love
💚 green heart love
💙 blue heart love
💜 purple heart love
🖤 black heart love dark
🤍 white heart love pure
🤎 brown heart love
💯 hundred points perfect score
💢 anger symbol mad
💥 collision explosion boom
💫 dizzy stars
💦 sweat droplets water
💨 dashing away fast wind
🕳️ hole
💣 bomb explosive
💬 speech bubble chat talk
👁️‍🗨️ eye speech bubble witness
🗨️ left speech bubble
🗯️ right anger bubble
💭 thought bubble thinking
💤 zzz sleeping
👋 waving hand hello bye
🤚 raised back hand stop
🖐️ hand fingers splayed high five
✋ raised hand stop high five
🖖 vulcan salute spock
👌 ok hand okay perfect
🤌 pinched fingers italian
🤏 pinching hand small little
✌️ victory hand peace
🤞 crossed fingers luck hope
🤟 love you gesture
🤘 sign horns rock metal
🤙 call me hand phone
👈 backhand index pointing left
👉 backhand index pointing right
👆 backhand index pointing up
🖕 middle finger rude
👇 backhand index pointing down
☝️ index pointing up
👍 thumbs up like good
👎 thumbs down dislike bad
✊ raised fist power solidarity
👊 oncoming fist punch bump
🤛 left facing fist bump
🤜 right facing fist bump
👏 clapping hands applause
🙌 raising hands celebration
👐 open hands hug
🤲 palms up together prayer
🤝 handshake deal agreement
🙏 folded hands pray please thanks
✍️ writing hand
💅 nail polish manicure
🤳 selfie phone
💪 flexed biceps strong muscle
🦾 mechanical arm robot
🦿 mechanical leg robot
🦵 leg kick
🦶 foot kick
👂 ear listen hear
🦻 ear hearing aid
👃 nose smell
🧠 brain think smart
🫀 anatomical heart
🫁 lungs breathe
🦷 tooth dental
🦴 bone skeleton
👀 eyes looking see
👁️ eye see look
👅 tongue lick taste
👄 mouth lips kiss
👶 baby child infant
🧒 child kid
👦 boy male child
👧 girl female child
🧑 person adult
👱 person blond hair
👨 man male adult
🧔 person beard
👩 woman female adult
🧓 older person elderly
👴 old man elderly male
👵 old woman elderly female
🙍 person frowning sad
🙎 person pouting angry
🙅 person gesturing no
🙆 person gesturing ok
💁 person tipping hand
🙋 person raising hand
🧏 deaf person
🙇 person bowing
🤦 person facepalming
🤷 person shrugging idk
👮 police officer cop
🕵️ detective spy investigate
💂 guard royal
🥷 ninja stealth
👷 construction worker builder
🤴 prince royal
👸 princess royal
👳 person turban
👲 person skullcap
🧕 woman headscarf hijab
🤵 person tuxedo formal
👰 person veil bride wedding
🤰 pregnant woman baby
🤱 breast feeding baby
👼 baby angel cherub
🎅 santa claus christmas
🤶 mrs claus christmas
🦸 superhero hero
🦹 supervillain villain
🧙 mage wizard magic
🧚 fairy magic
🧛 vampire dracula
🧜 merperson mermaid
🧝 elf fantasy
🧞 genie magic wish
🧟 zombie undead
💆 person massage spa
💇 person haircut salon
🚶 person walking
🧍 person standing
🧎 person kneeling
🏃 person running jogging
💃 woman dancing
🕺 man dancing
🕴️ person suit levitating
👯 people bunny ears party
🧖 person steamy room sauna
🧗 person climbing
🤺 person fencing sword
🏇 horse racing
⛷️ skier skiing snow
🏂 snowboarder winter
🏌️ person golfing
🏄 person surfing wave
🚣 person rowing boat
🏊 person swimming
⛹️ person bouncing ball basketball
🏋️ person lifting weights gym
🚴 person biking cycling
🚵 person mountain biking
🤸 person cartwheeling
🤼 people wrestling
🤽 person playing water polo
🤾 person playing handball
🤹 person juggling
🧘 person lotus position yoga meditation
🛀 person bath tub
🛌 person bed sleeping
🐶 dog face puppy
🐱 cat face kitty
🐭 mouse face
🐹 hamster face
🐰 rabbit face bunny
🦊 fox face
🐻 bear face
🐼 panda face
🐻‍❄️ polar bear
🐨 koala
🐯 tiger face
🦁 lion face
🐮 cow face
🐷 pig face
🐽 pig nose
🐸 frog face
🐵 monkey face
🙈 see no evil monkey
🙉 hear no evil monkey
🙊 speak no evil monkey
🐒 monkey
🦍 gorilla
🦧 orangutan
🐔 chicken
🐧 penguin
🐦 bird
🐤 baby chick
🐣 hatching chick
🐥 front facing baby chick
🦆 duck
🦅 eagle
🦉 owl
🦇 bat
🐺 wolf
🐗 boar
🐴 horse face
🦄 unicorn
🐝 honeybee bee
🪲 beetle bug
🐛 bug caterpillar
🦋 butterfly
🐌 snail
🐞 lady beetle ladybug
🐜 ant
🪰 fly
🪳 cockroach
🪱 worm
🦟 mosquito
🦗 cricket
🕷️ spider
🕸️ spider web
🦂 scorpion
🐢 turtle
🐍 snake
🦎 lizard
🦖 t-rex dinosaur
🦕 sauropod dinosaur
🐙 octopus
🦑 squid
🦐 shrimp
🦞 lobster
🦀 crab
🐡 blowfish
🐠 tropical fish
🐟 fish
🐬 dolphin
🐳 spouting whale
🐋 whale
🦈 shark
🐊 crocodile
🐅 tiger
🐆 leopard
🦓 zebra
🦏 rhinoceros
🦛 hippopotamus
🐘 elephant
🦣 mammoth
🦒 giraffe
🦘 kangaroo
🦬 bison
🐃 water buffalo
🐂 ox
🐄 cow
🐎 horse
🐖 pig
🐏 ram sheep
🐑 ewe sheep
🦙 llama
🐐 goat
🦌 deer
🐕 dog
🐩 poodle dog
🦮 guide dog
🐕‍🦺 service dog
🐈 cat
🐈‍⬛ black cat
🪶 feather
🐓 rooster
🦃 turkey
🦤 dodo bird
🦚 peacock
🦜 parrot
🦢 swan
🦩 flamingo
🕊️ dove peace
🐇 rabbit bunny
🦝 raccoon
🦨 skunk
🦡 badger
🦫 beaver
🦦 otter
🦥 sloth
🐁 mouse
🐀 rat
🐿️ chipmunk
🦔 hedgehog
🐾 paw prints
🐉 dragon
🐲 dragon face
🌵 cactus desert
🎄 christmas tree
🌲 evergreen tree pine
🌳 deciduous tree
🌴 palm tree tropical
🌱 seedling plant growing
🌿 herb plant
☘️ shamrock clover luck
🍀 four leaf clover luck
🎍 pine decoration
🎋 tanabata tree
🍃 leaf fluttering wind
🍂 fallen leaf autumn fall
🍁 maple leaf canada autumn
🌾 sheaf rice
🌺 hibiscus flower
🌻 sunflower
🌹 rose flower love
🥀 wilted flower dead
🌷 tulip flower
🌼 blossom flower
🌸 cherry blossom sakura
💐 bouquet flowers
🍄 mushroom fungus
🌰 chestnut nut
🎃 jack o lantern halloween pumpkin
🐚 spiral shell beach
🪸 coral reef ocean
🪨 rock stone
🪵 wood log
🌍 globe europe africa earth world
🌎 globe americas earth world
🌏 globe asia australia earth world
🌐 globe meridians earth world
🪐 ringed planet saturn
🌙 crescent moon night
🌛 first quarter moon face
🌜 last quarter moon face
🌚 new moon face
🌝 full moon face
🌞 sun face
⭐ star
🌟 glowing star sparkle
✨ sparkles magic
💫 dizzy star
☀️ sun sunny
🌤️ sun small cloud
⛅ sun behind cloud
🌥️ sun behind large cloud
🌦️ sun behind rain cloud
🌈 rainbow colors
☁️ cloud
🌧️ cloud rain
⛈️ cloud lightning rain storm thunder
🌩️ cloud lightning storm
🌨️ cloud snow
❄️ snowflake winter cold
☃️ snowman winter
⛄ snowman without snow winter
🌬️ wind face blowing
💨 dashing away fast wind
🌪️ tornado twister
🌫️ fog mist
🌊 water wave ocean
💧 droplet water
💦 sweat droplets water
☔ umbrella rain
☂️ umbrella
🌂 closed umbrella
⚡ high voltage lightning electricity
🔥 fire flame hot
⭐ star
🌟 glowing star
✨ sparkles magic
🍏 green apple fruit
🍎 red apple fruit
🍐 pear fruit
🍊 tangerine orange fruit
🍋 lemon fruit sour
🍌 banana fruit
🍉 watermelon fruit summer
🍇 grapes fruit wine
🍓 strawberry fruit
🫐 blueberries fruit
🍈 melon fruit
🍒 cherries fruit
🍑 peach fruit butt
🥭 mango fruit tropical
🍍 pineapple fruit tropical
🥥 coconut tropical
🥝 kiwi fruit
🍅 tomato vegetable
🍆 eggplant aubergine
🥑 avocado
🥦 broccoli vegetable
🥬 leafy green vegetable
🥒 cucumber vegetable pickle
🌶️ hot pepper spicy chili
🫑 bell pepper vegetable
🌽 ear corn vegetable
🥕 carrot vegetable
🫒 olive
🧄 garlic
🧅 onion
🥔 potato vegetable
🍠 roasted sweet potato
🥐 croissant bread pastry
🥯 bagel bread
🍞 bread loaf
🥖 baguette bread french
🥨 pretzel
🧀 cheese wedge
🥚 egg
🍳 cooking egg fried breakfast
🧈 butter
🥞 pancakes breakfast
🧇 waffle breakfast
🥓 bacon breakfast meat
🥩 cut meat steak beef
🍖 meat bone
🍗 poultry leg chicken
🌭 hot dog sausage
🍔 hamburger burger
🍟 french fries
🍕 pizza
🫓 flatbread
🥪 sandwich
🥙 stuffed flatbread
🧆 falafel
🌮 taco mexican
🌯 burrito mexican
🫔 tamale mexican
🥗 green salad healthy
🥘 shallow pan food cooking
🫕 fondue cheese
🍝 spaghetti pasta italian
🍜 steaming bowl noodles ramen
🍲 pot food soup stew
🍛 curry rice indian
🍣 sushi japanese
🍱 bento box japanese
🥟 dumpling
🦪 oyster seafood
🍤 fried shrimp tempura
🍙 rice ball onigiri
🍚 cooked rice
🍘 rice cracker
🍥 fish cake narutomaki
🥮 moon cake
🍢 oden japanese
🍡 dango japanese
🥡 takeout box chinese
🥠 fortune cookie
🥧 pie dessert
🍰 shortcake dessert birthday
🎂 birthday cake
🧁 cupcake
🍮 custard flan
🍭 lollipop candy
🍬 candy sweet
🍫 chocolate bar
🍿 popcorn movie
🍩 doughnut donut
🍪 cookie
🌰 chestnut
🥜 peanuts
🍯 honey pot bee
🥛 glass milk
🍼 baby bottle
🫖 teapot
☕ hot beverage coffee tea
🍵 teacup tea
🧃 beverage box juice
🥤 cup straw soda
🧋 bubble tea boba
🍶 sake japanese
🍺 beer mug
🍻 clinking beer mugs cheers
🥂 clinking glasses champagne toast
🍷 wine glass
🥃 tumbler glass whiskey
🍸 cocktail glass martini
🍹 tropical drink cocktail
🧉 mate drink
🍾 bottle popping cork champagne
🧊 ice cube cold
🥄 spoon utensil
🍴 fork knife utensil
🍽️ fork knife plate dining
🥣 bowl spoon cereal
🥡 takeout box
🥢 chopsticks
🧂 salt shaker
⚽ soccer ball football
🏀 basketball
🏈 american football
⚾ baseball
🥎 softball
🎾 tennis
🏐 volleyball
🏉 rugby football
🥏 flying disc frisbee
🎱 pool 8 ball billiards
🪀 yo yo toy
🏓 ping pong table tennis
🏸 badminton
🏒 ice hockey
🏑 field hockey
🥍 lacrosse
🏏 cricket game
🪃 boomerang
🥅 goal net
⛳ flag hole golf
🪁 kite flying
🏹 bow arrow archery
🎣 fishing pole
🤿 diving mask snorkel
🥊 boxing glove
🥋 martial arts uniform
🎽 running shirt
🛹 skateboard
🛼 roller skate
🛷 sled
⛸️ ice skate
🥌 curling stone
🎿 skis skiing
⛷️ skier skiing
🏂 snowboarder
🪂 parachute skydiving
🏋️ person lifting weights gym
🤼 people wrestling
🤸 person cartwheeling
🤺 person fencing
⛹️ person bouncing ball
🤾 person playing handball
🏌️ person golfing
🏇 horse racing
⛷️ skier
🏂 snowboarder
🏄 person surfing
🚣 person rowing boat
🏊 person swimming
🚴 person biking
🚵 person mountain biking
🎪 circus tent
🤹 person juggling
🎭 performing arts theater drama
🩰 ballet shoes dance
🎨 artist palette painting
🎬 clapper board movie film
🎤 microphone karaoke singing
🎧 headphone music audio
🎼 musical score
🎹 musical keyboard piano
🥁 drum music
🪘 long drum
🎷 saxophone jazz
🎺 trumpet music
🪗 accordion
🎸 guitar music rock
🪕 banjo country
🎻 violin music classical
🪈 flute music
🎲 game die dice
♟️ chess pawn
🎯 bullseye target darts
🎳 bowling
🎮 video game controller gaming
🕹️ joystick gaming arcade
🎰 slot machine casino gambling
🧩 puzzle piece jigsaw
🧸 teddy bear toy
🪆 nesting dolls matryoshka
🪅 pinata party
🪩 mirror ball disco
🎴 flower playing cards
🎭 performing arts theater
🖼️ framed picture art
🎨 artist palette painting
🧵 thread sewing
🪡 sewing needle
🧶 yarn knitting
🪢 knot rope
🛍️ shopping bags
📿 prayer beads
💎 gem stone diamond jewel
📯 postal horn
🎙️ studio microphone
📻 radio
🎚️ level slider
🎛️ control knobs
📱 mobile phone smartphone
📲 mobile phone arrow
☎️ telephone
📞 telephone receiver
📟 pager
📠 fax machine
🔌 electric plug
💻 laptop computer
🖥️ desktop computer
🖨️ printer
⌨️ keyboard
🖱️ computer mouse
🖲️ trackball
💾 floppy disk save
💿 optical disk cd
📀 dvd
🧮 abacus calculator
🎥 movie camera film
🎞️ film frames
📽️ film projector
🎬 clapper board movie
📺 television tv
📷 camera photo
📸 camera flash
📹 video camera
📼 videocassette vhs
🔍 magnifying glass left search
🔎 magnifying glass right search
🕯️ candle
💡 light bulb idea
🔦 flashlight
🏮 red paper lantern
🪔 diya lamp
📔 notebook decorative cover
📕 closed book
📖 open book reading
📗 green book
📘 blue book
📙 orange book
📚 books library stack
📓 notebook
📒 ledger
📃 page curl document
📜 scroll ancient
📄 page facing up document
📰 newspaper news
🗞️ rolled up newspaper
📑 bookmark tabs
🔖 bookmark
🏷️ label tag
💰 money bag
🪙 coin money
💴 yen banknote money
💵 dollar banknote money
💶 euro banknote money
💷 pound banknote money
💸 money wings flying
💳 credit card payment
🧾 receipt
💹 chart increasing yen
✉️ envelope email mail
📧 e mail email
📨 incoming envelope
📩 envelope arrow
📤 outbox tray
📥 inbox tray
📦 package box
📫 closed mailbox raised flag
📪 closed mailbox lowered flag
📬 open mailbox raised flag
📭 open mailbox lowered flag
📮 postbox
🗳️ ballot box
✏️ pencil
✒️ black nib pen
🖋️ fountain pen
🖊️ pen
🖌️ paintbrush art
🖍️ crayon
📝 memo note
💼 briefcase work business
📁 file folder
📂 open file folder
🗂️ card index dividers
📅 calendar date
📆 tear off calendar
🗒️ spiral notepad
🗓️ spiral calendar
📇 card index rolodex
📈 chart increasing up
📉 chart decreasing down
📊 bar chart statistics
📋 clipboard
📌 pushpin
📍 round pushpin location
📎 paperclip
🖇️ linked paperclips
📏 straight ruler
📐 triangular ruler
✂️ scissors cut
🗃️ card file box
🗄️ file cabinet
🗑️ wastebasket trash delete
🔒 locked padlock secure
🔓 unlocked padlock
🔏 locked pen
🔐 locked key
🔑 key
🗝️ old key
🔨 hammer tool
🪓 axe tool
⛏️ pick tool mining
⚒️ hammer pick tools
🛠️ hammer wrench tools
🗡️ dagger knife weapon
⚔️ crossed swords battle
🔫 water pistol gun
🪃 boomerang
🏹 bow arrow archery
🛡️ shield protection
🪚 carpentry saw
🔧 wrench tool
🪛 screwdriver tool
🔩 nut bolt
⚙️ gear settings cog
🗜️ clamp
⚖️ balance scale justice
🦯 white cane
🔗 link chain
⛓️ chains
🪝 hook
🧰 toolbox
🧲 magnet
🪜 ladder
⚗️ alembic chemistry
🧪 test tube science
🧫 petri dish science
🧬 dna genetics
🔬 microscope science
🔭 telescope astronomy
📡 satellite antenna
💉 syringe vaccine injection
🩸 drop blood
💊 pill medicine
🩹 adhesive bandage
🩼 crutch
🩺 stethoscope doctor
🩻 x ray skeleton
🚪 door
🛗 elevator
🪞 mirror reflection
🪟 window
🛏️ bed sleeping
🛋️ couch lamp
🪑 chair seat
🚽 toilet bathroom
🪠 plunger
🚿 shower bathroom
🛁 bathtub
🪤 mouse trap
🪒 razor shave
🧴 lotion bottle
🧷 safety pin
🧹 broom cleaning sweep
🧺 basket laundry
🧻 roll paper toilet
🪣 bucket
🧼 soap cleaning
🫧 bubbles
🪥 toothbrush dental
🧽 sponge cleaning
🧯 fire extinguisher
🛒 shopping cart
🚬 cigarette smoking
⚰️ coffin death
🪦 headstone grave
⚱️ funeral urn
🗿 moai statue easter island
🪧 placard sign
🪪 identification card id
🏧 atm sign
🚮 litter bin sign
🚰 potable water
♿ wheelchair accessible
🚹 mens room
🚺 womens room
🚻 restroom bathroom
🚼 baby symbol
🚾 water closet
🛂 passport control
🛃 customs
🛄 baggage claim
🛅 left luggage
⚠️ warning
🚸 children crossing
⛔ no entry
🚫 prohibited
🚳 no bicycles
🚭 no smoking
🚯 no littering
🚱 non potable water
🚷 no pedestrians
📵 no mobile phones
🔞 no one under eighteen
☢️ radioactive
☣️ biohazard
⬆️ up arrow
↗️ up right arrow
➡️ right arrow
↘️ down right arrow
⬇️ down arrow
↙️ down left arrow
⬅️ left arrow
↖️ up left arrow
↕️ up down arrow
↔️ left right arrow
↩️ right arrow curving left
↪️ left arrow curving right
⤴️ right arrow curving up
⤵️ right arrow curving down
🔃 clockwise arrows
🔄 counterclockwise arrows
🔙 back arrow
🔚 end arrow
🔛 on arrow
🔜 soon arrow
🔝 top arrow
🛐 place worship
⚛️ atom symbol science
🕉️ om symbol hindu
✡️ star david jewish
☸️ wheel dharma buddhist
☯️ yin yang balance
✝️ latin cross christian
☦️ orthodox cross
☪️ star crescent islam
☮️ peace symbol
🕎 menorah jewish
🔯 six pointed star
♈ aries zodiac
♉ taurus zodiac
♊ gemini zodiac
♋ cancer zodiac
♌ leo zodiac
♍ virgo zodiac
♎ libra zodiac
♏ scorpio zodiac
♐ sagittarius zodiac
♑ capricorn zodiac
♒ aquarius zodiac
♓ pisces zodiac
⛎ ophiuchus zodiac
🔀 shuffle tracks
🔁 repeat
🔂 repeat single
▶️ play button
⏩ fast forward
⏭️ next track
⏯️ play pause
◀️ reverse
⏪ fast reverse
⏮️ previous track
🔼 upwards button
⏫ fast up
🔽 downwards button
⏬ fast down
⏸️ pause
⏹️ stop
⏺️ record
⏏️ eject
🎦 cinema movie
🔅 dim brightness
🔆 bright brightness
📶 antenna bars signal
📳 vibration mode
📴 mobile phone off
♀️ female sign woman
♂️ male sign man
⚧️ transgender symbol
✖️ multiply heavy multiplication x
➕ plus add
➖ minus subtract
➗ divide
🟰 heavy equals sign
♾️ infinity
‼️ double exclamation mark
⁉️ exclamation question mark
❓ question mark red
❔ question mark white
❕ exclamation mark white
❗ exclamation mark red
〰️ wavy dash
💱 currency exchange
💲 heavy dollar sign
⚕️ medical symbol
♻️ recycling symbol
⚜️ fleur de lis
🔱 trident emblem
📛 name badge
🔰 japanese symbol beginner
⭕ hollow red circle
✅ check mark button
☑️ check box with check
✔️ check mark
❌ cross mark x
❎ cross mark button
➰ curly loop
➿ double curly loop
〽️ part alternation mark
✳️ eight spoked asterisk
✴️ eight pointed star
❇️ sparkle
©️ copyright
®️ registered
™️ trade mark
#️⃣ keycap hash hashtag
*️⃣ keycap asterisk star
0️⃣ keycap 0 zero
1️⃣ keycap 1 one
2️⃣ keycap 2 two
3️⃣ keycap 3 three
4️⃣ keycap 4 four
5️⃣ keycap 5 five
6️⃣ keycap 6 six
7️⃣ keycap 7 seven
8️⃣ keycap 8 eight
9️⃣ keycap 9 nine
🔟 keycap 10 ten
🔠 input latin uppercase
🔡 input latin lowercase
🔢 input numbers
🔣 input symbols
🔤 input latin letters
🅰️ a button blood type
🆎 ab button blood type
🅱️ b button blood type
🆑 cl button
🆒 cool button
🆓 free button
ℹ️ information
🆔 id button
Ⓜ️ circled m metro
🆕 new button
🆖 ng button
🅾️ o button blood type
🆗 ok button
🅿️ p button parking
🆘 sos button help emergency
🆙 up button
🆚 vs button versus
🈁 japanese here button
🈂️ japanese service charge button
🈷️ japanese monthly amount button
🈶 japanese not free of charge button
🈯 japanese reserved button
🉐 japanese bargain button
🈹 japanese discount button
🈚 japanese free of charge button
🈲 japanese prohibited button
🉑 japanese acceptable button
🈸 japanese application button
🈴 japanese passing grade button
🈳 japanese vacancy button
㊗️ japanese congratulations button
㊙️ japanese secret button
🈺 japanese open business button
🈵 japanese no vacancy button
🔴 red circle
🟠 orange circle
🟡 yellow circle
🟢 green circle
🔵 blue circle
🟣 purple circle
🟤 brown circle
⚫ black circle
⚪ white circle
🟥 red square
🟧 orange square
🟨 yellow square
🟩 green square
🟦 blue square
🟪 purple square
🟫 brown square
⬛ black large square
⬜ white large square
◼️ black medium square
◻️ white medium square
◾ black medium small square
◽ white medium small square
▪️ black small square
▫️ white small square
🔶 large orange diamond
🔷 large blue diamond
🔸 small orange diamond
🔹 small blue diamond
🔺 red triangle pointed up
🔻 red triangle pointed down
💠 diamond dot
🔘 radio button
🔳 white square button
🔲 black square button
🏁 chequered flag race finish
🚩 triangular flag
🎌 crossed flags japan
🏴 black flag
🏳️ white flag surrender
🏳️‍🌈 rainbow flag pride lgbt
🏳️‍⚧️ transgender flag
🏴‍☠️ pirate flag
🇦🇨 flag ascension island
🇦🇩 flag andorra
🇦🇪 flag united arab emirates
🇦🇫 flag afghanistan
🇦🇬 flag antigua barbuda
🇦🇮 flag anguilla
🇦🇱 flag albania
🇦🇲 flag armenia
🇦🇴 flag angola
🇦🇶 flag antarctica
🇦🇷 flag argentina
🇦🇸 flag american samoa
🇦🇹 flag austria
🇦🇺 flag australia
🇦🇼 flag aruba
🇦🇽 flag aland islands
🇦🇿 flag azerbaijan
🇧🇦 flag bosnia herzegovina
🇧🇧 flag barbados
🇧🇩 flag bangladesh
🇧🇪 flag belgium
🇧🇫 flag burkina faso
🇧🇬 flag bulgaria
🇧🇭 flag bahrain
🇧🇮 flag burundi
🇧🇯 flag benin
🇧🇱 flag st barthelemy
🇧🇲 flag bermuda
🇧🇳 flag brunei
🇧🇴 flag bolivia
🇧🇶 flag caribbean netherlands
🇧🇷 flag brazil
🇧🇸 flag bahamas
🇧🇹 flag bhutan
🇧🇻 flag bouvet island
🇧🇼 flag botswana
🇧🇾 flag belarus
🇧🇿 flag belize
🇨🇦 flag canada
🇨🇨 flag cocos islands
🇨🇩 flag congo kinshasa
🇨🇫 flag central african republic
🇨🇬 flag congo brazzaville
🇨🇭 flag switzerland
🇨🇮 flag cote ivoire
🇨🇰 flag cook islands
🇨🇱 flag chile
🇨🇲 flag cameroon
🇨🇳 flag china
🇨🇴 flag colombia
🇨🇵 flag clipperton island
🇨🇷 flag costa rica
🇨🇺 flag cuba
🇨🇻 flag cape verde
🇨🇼 flag curacao
🇨🇽 flag christmas island
🇨🇾 flag cyprus
🇨🇿 flag czechia
🇩🇪 flag germany
🇩🇬 flag diego garcia
🇩🇯 flag djibouti
🇩🇰 flag denmark
🇩🇲 flag dominica
🇩🇴 flag dominican republic
🇩🇿 flag algeria
🇪🇦 flag ceuta melilla
🇪🇨 flag ecuador
🇪🇪 flag estonia
🇪🇬 flag egypt
🇪🇭 flag western sahara
🇪🇷 flag eritrea
🇪🇸 flag spain
🇪🇹 flag ethiopia
🇪🇺 flag european union
🇫🇮 flag finland
🇫🇯 flag fiji
🇫🇰 flag falkland islands
🇫🇲 flag micronesia
🇫🇴 flag faroe islands
🇫🇷 flag france
🇬🇦 flag gabon
🇬🇧 flag united kingdom
🇬🇩 flag grenada
🇬🇪 flag georgia
🇬🇫 flag french guiana
🇬🇬 flag guernsey
🇬🇭 flag ghana
🇬🇮 flag gibraltar
🇬🇱 flag greenland
🇬🇲 flag gambia
🇬🇳 flag guinea
🇬🇵 flag guadeloupe
🇬🇶 flag equatorial guinea
🇬🇷 flag greece
🇬🇸 flag south georgia south sandwich islands
🇬🇹 flag guatemala
🇬🇺 flag guam
🇬🇼 flag guinea bissau
🇬🇾 flag guyana
🇭🇰 flag hong kong sar china
🇭🇲 flag heard mcdonald islands
🇭🇳 flag honduras
🇭🇷 flag croatia
🇭🇹 flag haiti
🇭🇺 flag hungary
🇮🇨 flag canary islands
🇮🇩 flag indonesia
🇮🇪 flag ireland
🇮🇱 flag israel
🇮🇲 flag isle man
🇮🇳 flag india
🇮🇴 flag british indian ocean territory
🇮🇶 flag iraq
🇮🇷 flag iran
🇮🇸 flag iceland
🇮🇹 flag italy
🇯🇪 flag jersey
🇯🇲 flag jamaica
🇯🇴 flag jordan
🇯🇵 flag japan
🇰🇪 flag kenya
🇰🇬 flag kyrgyzstan
🇰🇭 flag cambodia
🇰🇮 flag kiribati
🇰🇲 flag comoros
🇰🇳 flag st kitts nevis
🇰🇵 flag north korea
🇰🇷 flag south korea
🇰🇼 flag kuwait
🇰🇾 flag cayman islands
🇰🇿 flag kazakhstan
🇱🇦 flag laos
🇱🇧 flag lebanon
🇱🇨 flag st lucia
🇱🇮 flag liechtenstein
🇱🇰 flag sri lanka
🇱🇷 flag liberia
🇱🇸 flag lesotho
🇱🇹 flag lithuania
🇱🇺 flag luxembourg
🇱🇻 flag latvia
🇱🇾 flag libya
🇲🇦 flag morocco
🇲🇨 flag monaco
🇲🇩 flag moldova
🇲🇪 flag montenegro
🇲🇫 flag st martin
🇲🇬 flag madagascar
🇲🇭 flag marshall islands
🇲🇰 flag north macedonia
🇲🇱 flag mali
🇲🇲 flag myanmar burma
🇲🇳 flag mongolia
🇲🇴 flag macao sar china
🇲🇵 flag northern mariana islands
🇲🇶 flag martinique
🇲🇷 flag mauritania
🇲🇸 flag montserrat
🇲🇹 flag malta
🇲🇺 flag mauritius
🇲🇻 flag maldives
🇲🇼 flag malawi
🇲🇽 flag mexico
🇲🇾 flag malaysia
🇲🇿 flag mozambique
🇳🇦 flag namibia
🇳🇨 flag new caledonia
🇳🇪 flag niger
🇳🇫 flag norfolk island
🇳🇬 flag nigeria
🇳🇮 flag nicaragua
🇳🇱 flag netherlands
🇳🇴 flag norway
🇳🇵 flag nepal
🇳🇷 flag nauru
🇳🇺 flag niue
🇳🇿 flag new zealand
🇴🇲 flag oman
🇵🇦 flag panama
🇵🇪 flag peru
🇵🇫 flag french polynesia
🇵🇬 flag papua new guinea
🇵🇭 flag philippines
🇵🇰 flag pakistan
🇵🇱 flag poland
🇵🇲 flag st pierre miquelon
🇵🇳 flag pitcairn islands
🇵🇷 flag puerto rico
🇵🇸 flag palestinian territories
🇵🇹 flag portugal
🇵🇼 flag palau
🇵🇾 flag paraguay
🇶🇦 flag qatar
🇷🇪 flag reunion
🇷🇴 flag romania
🇷🇸 flag serbia
🇷🇺 flag russia
🇷🇼 flag rwanda
🇸🇦 flag saudi arabia
🇸🇧 flag solomon islands
🇸🇨 flag seychelles
🇸🇩 flag sudan
🇸🇪 flag sweden
🇸🇬 flag singapore
🇸🇭 flag st helena
🇸🇮 flag slovenia
🇸🇯 flag svalbard jan mayen
🇸🇰 flag slovakia
🇸🇱 flag sierra leone
🇸🇲 flag san marino
🇸🇳 flag senegal
🇸🇴 flag somalia
🇸🇷 flag suriname
🇸🇸 flag south sudan
🇸🇹 flag sao tome principe
🇸🇻 flag el salvador
🇸🇽 flag sint maarten
🇸🇾 flag syria
🇸🇿 flag eswatini
🇹🇦 flag tristan da cunha
🇹🇨 flag turks caicos islands
🇹🇩 flag chad
🇹🇫 flag french southern territories
🇹🇬 flag togo
🇹🇭 flag thailand
🇹🇯 flag tajikistan
🇹🇰 flag tokelau
🇹🇱 flag timor leste
🇹🇲 flag turkmenistan
🇹🇳 flag tunisia
🇹🇴 flag tonga
🇹🇷 flag turkey
🇹🇹 flag trinidad tobago
🇹🇻 flag tuvalu
🇹🇼 flag taiwan
🇹🇿 flag tanzania
🇺🇦 flag ukraine
🇺🇬 flag uganda
🇺🇲 flag us outlying islands
🇺🇳 flag united nations
🇺🇸 flag united states
🇺🇾 flag uruguay
🇺🇿 flag uzbekistan
🇻🇦 flag vatican city
🇻🇨 flag st vincent grenadines
🇻🇪 flag venezuela
🇻🇬 flag british virgin islands
🇻🇮 flag us virgin islands
🇻🇳 flag vietnam
🇻🇺 flag vanuatu
🇼🇫 flag wallis futuna
🇼🇸 flag samoa
🇽🇰 flag kosovo
🇾🇪 flag yemen
🇾🇹 flag mayotte
🇿🇦 flag south africa
🇿🇲 flag zambia
🇿🇼 flag zimbabwe
🏴󠁧󠁢󠁥󠁮󠁧󠁿 flag england
🏴󠁧󠁢󠁳󠁣󠁴󠁿 flag scotland
🏴󠁧󠁢󠁷󠁬󠁳󠁿 flag wales
EMOJIS
}

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Load recent emojis
load_recent() {
    [[ -f "$RECENT_FILE" ]] && cat "$RECENT_FILE"
}

# Save emoji to recent
save_recent() {
    local emoji="$1"

    # Create temp file with new emoji at top, remove duplicates
    {
        echo "$emoji"
        grep -v "^$emoji$" "$RECENT_FILE" 2>/dev/null | head -n "$((MAX_RECENT - 1))"
    } > "$RECENT_FILE.tmp"

    mv "$RECENT_FILE.tmp" "$RECENT_FILE"
}

# Show main menu
show_menu() {
    echo -e "$ICON_SEARCH\tSearch All"
    echo -e "$ICON_RECENT\tRecent"
    echo -e "$ICON_FACE\tSmileys & People"
    echo -e "$ICON_HEART\tSymbols & Hearts"
}

# Search emojis
search_emojis() {
    create_emoji_file

    local selection
    selection=$(cat "$EMOJI_FILE" | rofi -dmenu -i \
        -p "Emoji" \
        -mesg "Type to search" \
        -theme "$THEME")

    if [[ -n "$selection" ]]; then
        local emoji="${selection%% *}"
        vibe_copy "$emoji"
        save_recent "$emoji"
        vibe_notify "Emoji" "Copied: $emoji"
    fi
}

# Show recent emojis
show_recent() {
    local recent
    recent=$(load_recent)

    if [[ -z "$recent" ]]; then
        vibe_notify "Emoji" "No recent emojis"
        return
    fi

    local selection
    selection=$(echo "$recent" | rofi -dmenu -i \
        -p "Recent" \
        -mesg "Recent emojis" \
        -theme "$THEME")

    if [[ -n "$selection" ]]; then
        vibe_copy "$selection"
        save_recent "$selection"
        vibe_notify "Emoji" "Copied: $selection"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    vibe_need wl-copy wl-clipboard || exit 1

    # Direct search mode
    if [[ "$1" == "--search" ]] || [[ "$1" == "-s" ]]; then
        search_emojis
        exit 0
    fi

    local choice
    choice=$(show_menu | rofi -dmenu -i \
        -p "Emoji" \
        -theme "$THEME")

    [[ -z "$choice" ]] && exit 0

    local action="${choice##*$'\t'}"

    case "$action" in
        "Search All")
            search_emojis
            ;;
        Recent)
            show_recent
            ;;
        "Smileys & People"|"Symbols & Hearts")
            search_emojis
            ;;
    esac
}

main "$@"
