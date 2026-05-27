#!/usr/bin/env bash

pkill -f kitty

plasma-apply-wallpaperimage ~/NixOS/Pictures/Purple.jpg

mkdir -p /tmp/purplerice
mkdir -p /tmp/purplerice/.config

rm -f ~/.config/kwinrulesrc

cat << 'EOF' > ~/.config/kwinrulesrc
[General]
count=16
rules=994a0f1d-2ade-4e2b-9d93-c49010f0d845,fetch,clock,bonsai,aqua,cal,weather,stats,love,lavat,lyrics,matrix,visualizer,pipes

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

[fetch]
position=1940,20
size=640,410
positionrule=3
sizerule=3
title=fetch
titlematch=1

[clock]
position=2600,20
size=910,410
positionrule=3
sizerule=3
title=clock
titlematch=1

[bonsai]
position=3530,20
size=450,410
positionrule=3
sizerule=3
title=bonsai
titlematch=1

[aqua]
position=4000,20
size=460,200
positionrule=3
sizerule=3
title=asciiquarium
titlematch=1

[stats]
position=4000,240
size=460,400
positionrule=3
sizerule=3
title=stats
titlematch=1

[weather]
position=4000,660
size=460,280
positionrule=3
sizerule=3
title=weather
titlematch=1

[love]
position=1940,450
size=640,490
positionrule=3
sizerule=3
title=love
titlematch=1

[lavat]
position=2600,450
size=655,490
positionrule=3
sizerule=3
title=lavat
titlematch=1

[lyrics]
position=3275,450
size=705,490
positionrule=3
sizerule=3
title=lyrics
titlematch=1

[matrix]
position=1940,960
size=350,460
positionrule=3
sizerule=3
title=matrix
titlematch=1

[visualizer]
position=2310,960
size=950,460
positionrule=3
sizerule=3
title=visualizer
titlematch=1

[pipes]
position=3280,960
size=580,460
positionrule=3
sizerule=3
title=pipes
titlematch=1

[cal]
position=3880,960
size=580,460
positionrule=3
sizerule=3
title=calendar
titlematch=1

[d96be141-bbbd-461e-bcdb-d4a979e9324b]
Description=Kitty Work
size=1600,800
sizerule=3
EOF

qdbus org.kde.KWin /KWin reconfigure
sleep 1

cat << 'EOF' > /tmp/purplerice/fastfetch.jsonc
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/NixOS/Pictures/LogoPurple.png",
        "type": "kitty",
        "width": 24,
        "height": 10,
        "padding": { "top": 2, "left": 2 }
    },
    "display": {
        "separator": " ➜ ",
        "color": { "keys": "magenta" }
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

cat << 'EOF' > /tmp/purplerice/kitty.conf
background         #0f0d1a
foreground         #f5e0dc
background_opacity 0.2
background_blur    40
window_padding_width 12
window_margin_width 15
confirm_os_window_close 0
window_border_width 1pt
active_border_color #cba6f7
inactive_border_color #313244
hide_window_decorations yes
font_family        JetBrains Mono
font_size          11
cursor             #0f0d1a
cursor_text_color  #0f0d1a
color4 #cba6f7
color12 #cba6f7
color5 #f5c2e7
color13 #f5c2e7
color2 #f5c2e7
color10 #cba6f7
linux_display_server wayland
shell_integration no-rc
repaint_delay 10
input_delay 3
sync_to_monitor yes
EOF

cat << 'EOF' > /tmp/purplerice/cava.conf
[general]
framerate = 60
bars = 0
[input]
method = pulse
source = auto
[color]
gradient = 1
gradient_count = 2
gradient_color_1 = '#cba6f7'
gradient_color_2 = '#f5c2e7'
EOF

cat << 'EOF' > /tmp/purplerice/sys_info.sh
#!/usr/bin/env bash
PURPLE='\033[38;2;203;166;247m'
PINK='\033[38;2;245;194;231m'
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
  echo -e "${PURPLE}${BOLD}SYSTEM STATS${NC}"
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

cat << 'EOF' > /tmp/purplerice/weather.sh
#!/usr/bin/env bash
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'
while true; do
    tput civis
    clear
    weather_data=$(curl -s "wttr.in/Warsaw?format=%c;%t;%C;%w;%h;%P")
    IFS=';' read -r icon temp desc wind humi pres <<< "$weather_data"
    echo -e "\n\n"
    PAD="  "
    echo -e "${PAD}${PURPLE}󰖐  WEATHER${NC}"
    echo -e "${PAD}${WHITE}-----------${NC}"
    print_line() {
        echo -e "${PAD}${PURPLE}$1 $2${NC} ${PURPLE}➜${NC} ${WHITE}$3${NC}"
    }
    print_line "󰔄" "Location   " "PL"
    print_line "󰖐" "Conditions " "${icon}${desc}"
    print_line "󱩄" "Temperature" "${temp}"
    print_line "󰖝" "Wind       " "${wind}"
    print_line "󰖚" "Humidity   " "${humi}"
    sleep 600
done
EOF

chmod +x /tmp/purplerice/sys_info.sh
chmod +x /tmp/purplerice/weather.sh

FLAGS="--config /tmp/purplerice/kitty.conf --override remember_window_size=no --override shell_integration=disabled"
PURPLE_COLORS="--override color1=#cba6f7 --override color2=#f5c2e7 --override color3=#eba0ac --override color4=#cba6f7 --override color5=#f5c2e7 --override color6=#eba0ac --override color7=#cdd6f4 --override color8=#585b70 --override color9=#cba6f7 --override color10=#f5c2e7 --override color11=#eba0ac --override color12=#cba6f7 --override color13=#f5c2e7 --override color14=#eba0ac --override color15=#f5e0dc"

kitty --title "fetch" $FLAGS sh -c "tput civis; fastfetch -c /tmp/purplerice/fastfetch.jsonc; tail -f /dev/null" &
kitty --title "clock" $FLAGS sh -c "tty-clock -S -c -C 5 -b -B" &
kitty --title "calendar" $FLAGS --override font_size=13 --override window_padding_width=60 sh -c "tput civis; echo -e '\033[1;35m'; cal; tail -f /dev/null" &
kitty --title "weather" $FLAGS sh -c "tput civis; /tmp/purplerice/weather.sh; tail -f /dev/null" &
kitty --title "stats" $FLAGS sh -c "/tmp/purplerice/sys_info.sh" &
kitty --title "love" $FLAGS sh -c "tput civis; clear; echo -e '\033[1;35m'; center_text() { local text=\$1; local width=\$(tput cols); local text_width=\$(toilet -f mono9 \"\$text\" | wc -L); local pad=\$(( (width - text_width) / 2 )); [ \$pad -lt 0 ] && pad=0; toilet -f mono9 \"\$text\" | sed \"s/^/\$(printf '%*s' \$pad '')/\"; }; tput cup 6 0; center_text \"naxce\"; tail -f /dev/null" &
kitty --title "visualizer" $FLAGS sh -c "cava -p /tmp/purplerice/cava.conf" &
kitty --title "matrix" $FLAGS sh -c "tput civis; cmatrix -b -C magenta" &
kitty --title "bonsai" $FLAGS $PURPLE_COLORS sh -c "cbonsai -l -b 1 || tail -f /dev/null" &
kitty --title "lavat" $FLAGS sh -c "lavat -c magenta -r 1; tail -f /dev/null" &
kitty --title "asciiquarium" $FLAGS $PURPLE_COLORS --override font_size=6 --override window_padding_width=0 sh -c "asciiquarium -t" &
kitty --title "pipes" $FLAGS $PURPLE_COLORS sh -c "pipes-rs -c ansi --palette default -k curved -b true || tail -f /dev/null" &
kitty --title "lyrics" $FLAGS sh -c "sptlrx --config /tmp/purplerice/sptlrx.yaml" &

disown
exit 0