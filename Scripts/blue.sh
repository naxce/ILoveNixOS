#!/usr/bin/env bash

pkill -f kitty

plasma-apply-wallpaperimage ~/NixOS/Pictures/Blue.jpg

mkdir -p /tmp/bluerice
mkdir -p /tmp/bluerice/.config

rm -f ~/.config/kwinrulesrc

cat << 'EOF' > ~/.config/kwinrulesrc
[0ea3dfbd-6d9e-45fd-af9a-a6e1e640b044]
position=3560,760
positionrule=3
size=480,400
sizerule=3

[27d4431a-8f34-4518-8b25-1f6e404a675d]
Description=Cava
position=2560,1160
positionrule=3
size=1280,260
sizerule=3
title=visualizer
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[2982c3d7-5cd6-42f9-ab5e-def10a474c73]
Description=Pipes
position=3860,1160
positionrule=3
size=600,260
sizerule=3
title=pipes
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[409d8155-6d47-4643-9cd9-47cefd42888b]
Description=Fastfetch
position=1940,20
positionrule=3
size=600,350
sizerule=3
title=fetch
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[65fd0069-5fee-4500-85a2-b4396a0e2f5e]
Description=Lyrics
position=4060,215
positionrule=3
size=400,925
sizerule=3
title=lyrics
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[6c7e549b-c22c-455c-a7de-20b75bfb124b]
Description=Lavat
position=3560,390
positionrule=3
size=480,750
sizerule=3
title=lavat
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[8264feb7-05a8-4d36-8d71-fdff67f3a4e8]
Description=Display3D
position=1940,390
positionrule=3
size=600,750
sizerule=3
title=display3d
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[994a0f1d-2ade-4e2b-9d93-c49010f0d845]
Description=No Taskbar
noborder=true
noborderrule=3
skippager=true
skippagerrule=3
skipswitcher=true
skipswitcherrule=3
skiptaskbar=true
skiptaskbarrule=3
wmclass=kitty
wmclassmatch=1

[General]
count=16
rules=6c7e549b-c22c-455c-a7de-20b75bfb124b,ed5c2b8f-2782-4b54-8aca-d01ac4022fa2,994a0f1d-2ade-4e2b-9d93-c49010f0d845,409d8155-6d47-4643-9cd9-47cefd42888b,8264feb7-05a8-4d36-8d71-fdff67f3a4e8,b96c50d8-9f86-4343-a9cb-4e08744afa01,ccc43692-cd2c-4ff8-8c53-d92c34050f61,a1566e1d-8ab4-41e5-b58b-4c1e59ba5298,e7bf94cf-a49b-4b9b-ad1b-688142d172da,e088a8f9-bdf2-48b6-acd9-ab80d6f9870f,b7f4a35c-5cac-4568-bbd9-e5ffc19e2495,27d4431a-8f34-4518-8b25-1f6e404a675d,d25fa3b2-4b3d-4ead-9ad0-225d36afb87d,65fd0069-5fee-4500-85a2-b4396a0e2f5e,b98ba038-f78b-4cdf-9a5d-ea3f32c4f19b,2982c3d7-5cd6-42f9-ab5e-def10a474c73

[a1566e1d-8ab4-41e5-b58b-4c1e59ba5298]
Description=Calendar
position=2560,390
positionrule=3
size=330,300
sizerule=3
title=calendar
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[a8510448-b7a3-4ff5-9cc7-fbe4e0660e10]
position=3760,20
positionrule=3
size=640,400
sizerule=3

[b7f4a35c-5cac-4568-bbd9-e5ffc19e2495]
Description=Love
position=2910,660
positionrule=3
size=630,480
sizerule=3
title=love
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[b96c50d8-9f86-4343-a9cb-4e08744afa01]
Description=Matrix
position=1940,1160
positionrule=3
size=600,260
sizerule=3
title=matrix
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[b98ba038-f78b-4cdf-9a5d-ea3f32c4f19b]
Description=CBonsai
position=3560,390
positionrule=3
size=480,350
sizerule=3
title=bonsai
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[ccc43692-cd2c-4ff8-8c53-d92c34050f61]
Description=Clock
position=2560,20
positionrule=3
size=1110,350
sizerule=3
title=clock
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[d25fa3b2-4b3d-4ead-9ad0-225d36afb87d]
Description=Asciiquarium
position=4060,20
positionrule=3
size=400,175
sizerule=3
title=asciiquarium
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[e088a8f9-bdf2-48b6-acd9-ab80d6f9870f]
Description=Stats
position=2560,710
positionrule=3
size=330,430
sizerule=3
title=stats
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[e669cee5-45f1-4755-aa42-61b901341836]
position=3760,20
positionrule=3
size=400,400
sizerule=3

[e7bf94cf-a49b-4b9b-ad1b-688142d172da]
Description=Weather
position=2910,390
positionrule=3
size=630,250
sizerule=3
title=weather
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[ed5c2b8f-2782-4b54-8aca-d01ac4022fa2]
Description=CBonsai
position=3690,20
positionrule=3
size=350,350
sizerule=3
title=cbonsai
titlematch=1
types=1
wmclass=kitty
wmclassmatch=1

[d96be141-bbbd-461e-bcdb-d4a979e9324b]
Description=Kitty Work
size=1600,800
sizerule=3
EOF

qdbus org.kde.KWin /KWin reconfigure
sleep 1

cat << 'EOF' > /tmp/bluerice/kitty.conf
background         #0a0f18
foreground         #dce4f0
background_opacity 0.1
background_blur    50
window_padding_width 15
confirm_os_window_close 0
window_margin_width 12
window_border_width 1pt
active_border_color #89b4fa
inactive_border_color #1c2541
draw_minimal_borders yes
hide_window_decorations yes
cursor             #89b4fa
cursor_text_color  #0a0f18
cursor_shape       beam
font_family        Fira Code
font_size          11
color0 #1e1e2e
color8 #585b70
color1 #f38ba8
color9 #f38ba8
color2 #a6e3a1
color10 #a6e3a1
color3 #f9e2af
color11 #f9e2af
color4 #89b4fa
color12 #89b4fa
color5 #f5c2e7
color13 #f5c2e7
color6 #94e2d5
color14 #94e2d5
color7 #bac2de
color15 #a6adc8
linux_display_server wayland
shell_integration no-rc
repaint_delay 10
input_delay 3
sync_to_monitor yes
EOF

cat << 'EOF' > /tmp/bluerice/cava.conf
[general]
framerate = 90
bars = 44
[color]
gradient = 1
gradient_count = 6
gradient_color_1 = '#0a1128'
gradient_color_2 = '#1c2541'
gradient_color_3 = '#3a506b'
gradient_color_4 = '#5bc0be'
gradient_color_5 = '#89b4fa'
gradient_color_6 = '#ffffff'
[smoothing]
integral = 50
monstercat = 0
waves = 1
EOF

cat << 'EOF' > /tmp/bluerice/fastfetch.jsonc
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/NixOS/Pictures/LogoBlue.png",
        "type": "kitty",
        "width": 22,
        "height": 10,
        "padding": { "top": 2, "left": 2 }
    },
    "display": {
        "separator": " ➜ ",
        "color": { "keys": "blue" }
    },
    "modules": [
        "title",
        "separator",
        { "type": "os", "key": "󱄅", "format": "{2} {8}" },
        { "type": "kernel", "key": "󰌽", "format": "{2}" },
        { "type": "uptime", "key": "󱎫" },
        { "type": "shell", "key": "󱆃" },
        { "type": "cpu", "key": "󰻠", "format": "{1}" },
        { "type": "gpu", "key": "󰢮", "hideType": "integrated", "format": "{2}" },
        { 
            "type": "display", 
            "key": "󰍹", 
            "compactType": "original-with-refresh",
            "format": "{1}x{2} @ {3}Hz" 
        },
        { "type": "memory", "key": "󰑭" },
        { "type": "localip", "key": "󰩟", "showIpv6": false }
    ]
}
EOF

cat << 'EOF' > /tmp/bluerice/sptlrx.yaml
player: "mpris"
ignoreErrors: true
timerInterval: 200
updateInterval: 500
omitTitle: false
centerLyrics: true
style:
  hAlignment: center
  lineHeight: 2
  before:
    foreground: "#666666"
    faint: true
  current:
    foreground: "#ffffff"
    bold: true
  after:
    foreground: "#666666"
    faint: true
mpris:
  players: ["chromium", "cider", "spotify"]
EOF

cat << 'EOF' > /tmp/bluerice/sys_info.sh
#!/usr/bin/env bash
BLUE='\033[38;2;137;180;250m'
CYAN='\033[38;2;137;220;235m'
BOLD='\033[1m'
NC='\033[0m'
tput civis
while true; do
  CPU_USAGE=$(awk '/^cpu / {u=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", u}' /proc/stat)
  CPU_TEMP=$(sensors 2>/dev/null | awk '/Tctl|Package id 0/ {print int($2); exit}')
  [ -z "$CPU_TEMP" ] && CPU_TEMP="--"
  GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
  GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | tr -d ' ')
  [ -z "$GPU_USAGE" ] && GPU_USAGE="--"
  [ -z "$GPU_TEMP" ] && GPU_TEMP="--"
  RAM_USED=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.1f", (t-a)/1024/1024}' /proc/meminfo)
  RAM_PERCENT=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.0f", (t-a)/t*100}' /proc/meminfo)
  MB_TEMP=$(sensors 2>/dev/null | awk '/Composite/ {print int($2); exit}')
  [ -z "$MB_TEMP" ] && MB_TEMP="--"
  tput cup 0 0
  echo -e "${BLUE}${BOLD}SYSTEM${NC}"
  echo "----------------------"
  printf "${BOLD}${CYAN}CPU${NC}  %-3s%%   %3s°C\n" "$CPU_USAGE" "$CPU_TEMP"
  printf "${BOLD}${CYAN}GPU${NC}  %-3s%%   %3s°C\n" "$GPU_USAGE" "$GPU_TEMP"
  printf "${BOLD}${CYAN}RAM${NC}  %-5s  %3s%%\n" "$RAM_USED" "$RAM_PERCENT"
  printf "${BOLD}${CYAN}MBD${NC} %3s°C\n" "$MB_TEMP"
  echo "----------------------"
  sleep 2
done
EOF

cat << 'EOF' > /tmp/bluerice/weather.sh
#!/usr/bin/env bash
BLUE='\033[1;34m'
WHITE='\033[1;37m'
NC='\033[0m'
while true; do
    tput civis
    clear
    weather_data=$(curl -s "wttr.in/Warsaw?format=%c;%t;%C;%w;%h;%P")
    IFS=';' read -r icon temp desc wind humi pres <<< "$weather_data"
    echo -e "\n\n"
    PAD="  "
    echo -e "${PAD}${BLUE}󰖐  WEATHER${NC}"
    echo -e "${PAD}${WHITE}-----------${NC}"
    print_line() {
        echo -e "${PAD}${BLUE}$1 $2${NC} ${BLUE}➜${NC} ${WHITE}$3${NC}"
    }
    print_line "󰔄" "Location   " "PL"
    print_line "󰖐" "Conditions " "${icon}${desc}"
    print_line "󱩄" "Temperature" "${temp}"
    print_line "󰖝" "Wind       " "${wind}"
    print_line "󰖚" "Humidity   " "${humi}"
    print_line "󰓅" "Pressure   " "${pres}"
    sleep 600
done
EOF

chmod +x /tmp/bluerice/sys_info.sh
chmod +x /tmp/bluerice/weather.sh

sleep 1

FLAGS="--config /tmp/bluerice/kitty.conf --override remember_window_size=no --override shell_integration=disabled"

kitty --title "fetch" $FLAGS sh -c "tput civis; fastfetch -c /tmp/bluerice/fastfetch.jsonc; tail -f /dev/null" &
kitty --title "display3d" $FLAGS sh -c "display3d ~/NixOS/resources/blahaj.obj -t 0,0,4.5" &
kitty --title "matrix" $FLAGS sh -c "tput civis; cmatrix -C blue -s" &
kitty --title "clock" $FLAGS sh -c "tty-clock -S -c -C 4 -b -B || tail -f /dev/null" &
kitty --title "calendar" $FLAGS sh -c "tput civis; echo -e '\n\n\033[1;34m'; cal; tail -f /dev/null" &
kitty --title "weather" $FLAGS sh -c "tput civis; /tmp/bluerice/weather.sh; tail -f /dev/null" &
kitty --title "stats" $FLAGS sh -c "/tmp/bluerice/sys_info.sh" &
kitty --title "love" $FLAGS --override window_padding_width=0 --override window_margin_width=0 sh -c "tput civis; clear; echo -e '\033[1;34m'; center_text() { local text=\$1; local width=\$(tput cols); local text_width=\$(toilet -f mono9 \"\$text\" | wc -L); local pad=\$(( (width - text_width) / 2 )); [ \$pad -lt 0 ] && pad=0; toilet -f mono9 \"\$text\" | sed \"s/^/\$(printf '%*s' \$pad '')/\"; }; tput cup 4 0; center_text \"I\"; tput cup 12 0; center_text \"<3\"; tput cup 20 0; center_text \"JULKA\"; tail -f /dev/null" &
kitty --title "visualizer" $FLAGS sh -c "cava -p /tmp/bluerice/cava.conf || tail -f /dev/null" &
kitty --title "cbonsai" $FLAGS --override color1=#89b4fa --override color2=#74c7ec --override color3=#94e2d5 --override color4=#89b4fa --override color5=#74c7ec --override color6=#94e2d5 --override color7=#bac2de --override color8=#585b70 --override color9=#89b4fa --override color10=#74c7ec --override color11=#94e2d5 --override color12=#89b4fa --override color13=#74c7ec --override color14=#94e2d5 --override color15=#a6adc8 sh -c "cbonsai -l -b 1 || tail -f /dev/null" &
kitty --title "lavat" $FLAGS --override window_padding_width=0 sh -c "lavat -c blue -r 1; tail -f /dev/null" &
kitty --title "asciiquarium" $FLAGS --override font_size=6 --override window_padding_width=0 --override placement_strategy=center sh -c "asciiquarium -t || tail -f /dev/null" &
kitty --title "pipes" $FLAGS --override color1=#89b4fa --override color2=#74c7ec --override color3=#94e2d5 --override color4=#89b4fa --override color5=#74c7ec --override color6=#94e2d5 --override color7=#bac2de --override color8=#585b70 --override color9=#89b4fa --override color10=#74c7ec --override color11=#94e2d5 --override color12=#89b4fa --override color13=#74c7ec --override color14=#94e2d5 --override color15=#a6adc8 sh -c "pipes-rs -c ansi --palette default -k curved -b true || tail -f /dev/null" &
kitty --title "lyrics" $FLAGS sh -c "sptlrx --config /tmp/bluerice/sptlrx.yaml --player mpris || tail -f /dev/null" &

disown
exit 0