#!/usr/bin/env bash

pkill -f kitty

plasma-apply-wallpaperimage ~/NixOS/Pictures/Red.jpg

mkdir -p /tmp/redrice
mkdir -p /tmp/redrice/.config

rm -f ~/.config/kwinrulesrc

cat << 'EOF' > ~/.config/kwinrulesrc
[General]
count=15
rules=d4f5e6a7-b8c9-4d0e-9f1a-2b3c4d5e6f7a,fetch,clock,bonsai,aqua,cal,weather,stats,lavat,lyrics,matrix,visualizer,pipes

[d4f5e6a7-b8c9-4d0e-9f1a-2b3c4d5e6f7a]
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

[lyrics]
position=1940,20
size=500,1400
positionrule=3
sizerule=3
title=lyrics
titlematch=1

[stats]
position=2460,20
size=1000,430
positionrule=3
sizerule=3
title=stats
titlematch=1

[fetch]
position=3480,20
size=980,430
positionrule=3
sizerule=3
title=fetch
titlematch=1

[weather]
position=2460,470
size=480,330
positionrule=3
sizerule=3
title=weather
titlematch=1

[cal]
position=2960,470
size=500,330
positionrule=3
sizerule=3
title=calendar
titlematch=1

[clock]
position=3480,470
size=980,330
positionrule=3
sizerule=3
title=clock
titlematch=1

[matrix]
position=2460,820
size=2000,120
positionrule=3
sizerule=3
title=matrix
titlematch=1

[bonsai]
position=2460,960
size=700,300
positionrule=3
sizerule=3
title=bonsai
titlematch=1

[pipes]
position=3180,960
size=700,300
positionrule=3
sizerule=3
title=pipes
titlematch=1

[lavat]
position=3900,960
size=560,220
positionrule=3
sizerule=3
title=lavat
titlematch=1

[aqua]
position=3900,1200
size=560,220
positionrule=3
sizerule=3
title=asciiquarium
titlematch=1

[visualizer]
position=2460,1280
size=1420,140
positionrule=3
sizerule=3
title=visualizer
titlematch=1
EOF

qdbus org.kde.KWin /KWin reconfigure
sleep 1

cat << 'EOF' > /tmp/redrice/fastfetch.jsonc
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/NixOS/Pictures/NixRed.png",
        "type": "kitty",
        "width": 24,
        "height": 10,
        "padding": { "top": 2, "left": 2 }
    },
    "display": {
        "separator": " ➜ ",
        "color": { "keys": "red" }
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

cat << 'EOF' > /tmp/redrice/kitty.conf
background         #0a0505
foreground         #f2c0c0
background_opacity 0.2
background_blur    40
window_padding_width 12
window_margin_width 5
confirm_os_window_close 0
window_border_width 1pt
active_border_color #ff5555
inactive_border_color #310000
hide_window_decorations yes
font_family        JetBrains Mono
font_size          10
cursor             #ff5555
color4 #ff5555
color12 #ff5555
color2 #ff5555
color10 #ff5555
linux_display_server wayland
shell_integration no-rc
EOF

cat << 'EOF' > /tmp/redrice/sys_info.sh
#!/usr/bin/env bash
RED='\033[38;2;255;85;85m'
PINK='\033[38;2;255;182;193m'
BOLD='\033[1m'
NC='\033[0m'
tput civis
while true; do
  UPTIME=$(awk '{printf "%dh %dm", $1/3600, ($1%3600)/60}' /proc/uptime)
  CPU_USAGE=$(awk '/^cpu / {u=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", u}' /proc/stat)
  CPU_TEMP=$(sensors 2>/dev/null | awk '/Tctl|Package id 0/ {print int($2); exit}')
  [ -z "$CPU_TEMP" ] && CPU_TEMP="--"
  RAM_USED=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.1f", (t-a)/1024/1024}' /proc/meminfo)
  RAM_PERCENT=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.0f", (t-a)/t*100}' /proc/meminfo)
  DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
  KERNEL_VER=$(uname -r | cut -d'-' -f1)
  
  tput cup 0 0
  echo -e "${RED}${BOLD}SYSTEM STATS${NC}"
  echo "----------------------"
  printf "${BOLD}${PINK}CPU${NC}  %-3s%%   %3s°C\n" "$CPU_USAGE" "$CPU_TEMP"
  printf "${BOLD}${PINK}RAM${NC}  %-5s  %3s%%\n" "$RAM_USED" "$RAM_PERCENT"
  printf "${BOLD}${PINK}DSK${NC}  %-13s\n" "$DISK_USAGE"
  printf "${BOLD}${PINK}KER${NC}  %-13s\n" "$KERNEL_VER"
  printf "${BOLD}${PINK}UPT${NC}  %s\n" "$UPTIME"
  echo "----------------------"
  sleep 2
done
EOF

cat << 'EOF' > /tmp/redrice/weather.sh
#!/usr/bin/env bash
RED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'
while true; do
    tput civis
    clear
    weather_data=$(curl -s "wttr.in/Warsaw?format=%c;%t;%C;%w;%h;%P")
    IFS=';' read -r icon temp desc wind humi pres <<< "$weather_data"
    echo -e "\n\n"
    PAD="  "
    echo -e "${PAD}${RED}󰖐  WEATHER${NC}"
    echo -e "${PAD}${WHITE}-----------${NC}"
    print_line() {
        echo -e "${PAD}${RED}$1 $2${NC} ${RED}➜${NC} ${WHITE}$3${NC}"
    }
    print_line "󰔄" "Location   " "PL"
    print_line "󰖐" "Conditions " "${icon}${desc}"
    print_line "󱩄" "Temperature" "${temp}"
    print_line "󰖝" "Wind       " "${wind}"
    print_line "󰖚" "Humidity   " "${humi}"
    sleep 600
done
EOF

cat << 'EOF' > /tmp/redrice/cava.conf
[general]
framerate = 60
autosens = 1
bars = 0
bar_width = 1
bar_spacing = 1

[input]
method = pulse
source = auto

[output]
method = ncurses

[color]
gradient = 1
gradient_count = 2
gradient_color_1 = '#ff5555'
gradient_color_2 = '#ff0000'
EOF

chmod +x /tmp/redrice/sys_info.sh
chmod +x /tmp/redrice/weather.sh

FLAGS="--config /tmp/redrice/kitty.conf --override remember_window_size=no --override shell_integration=disabled"
RED_COLORS="--override color1=#ff5555 --override color2=#ff0000 --override color3=#ff7eb3 --override color4=#ff5555 --override color5=#ff0000 --override color6=#ff7eb3 --override color7=#cdd6f4 --override color8=#585b70 --override color9=#ff5555 --override color10=#ff0000 --override color11=#ff7eb3 --override color12=#ff5555 --override color13=#ff0000 --override color14=#ff7eb3 --override color15=#f2c0c0"

kitty --title "lyrics" $FLAGS sh -c "sptlrx --config /tmp/redrice/sptlrx.yaml" &
kitty --title "stats" $FLAGS --override font_size=13 sh -c "/tmp/redrice/sys_info.sh" &
kitty --title "fetch" $FLAGS sh -c "tput civis; fastfetch -c /tmp/redrice/fastfetch.jsonc; tail -f /dev/null" &
kitty --title "weather" $FLAGS sh -c "/tmp/redrice/weather.sh" &
kitty --title "calendar" $FLAGS --override font_size=11 sh -c "tput civis; echo -e '\033[1;31m'; cal; tail -f /dev/null" &
kitty --title "clock" $FLAGS sh -c "tty-clock -S -c -C 1 -b -B" &
kitty --title "matrix" $FLAGS sh -c "tput civis; cmatrix -b -C red" &
kitty --title "bonsai" $FLAGS $RED_COLORS sh -c "cbonsai -l -b 1" &
kitty --title "pipes" $FLAGS $RED_COLORS sh -c "pipes-rs -k curved" &
kitty --title "lavat" $FLAGS sh -c "lavat -c red -r 1" &
kitty --title "asciiquarium" $FLAGS $RED_COLORS --override font_size=6 sh -c "asciiquarium -t" &
kitty --title "visualizer" $FLAGS sh -c "sleep 3; cava -p /tmp/redrice/cava.conf" &

disown
exit 0