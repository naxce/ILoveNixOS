#!/usr/bin/env bash

BLUE='\033[1;34m'
WHITE='\033[1;37m'
GREY='\033[0;90m'
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
        local icon=$1
        local label=$2
        local value=$3
        echo -e "${PAD}${BLUE}${icon} ${label}${NC} ${BLUE}➜${NC} ${WHITE}${value}${NC}"
    }

    print_line "󰔄" "Location   " "PL"
    print_line "󰖐" "Conditions " "${icon}${desc}"
    print_line "󱩄" "Temperature" "${temp}"
    print_line "󰖝" "Wind       " "${wind}"
    print_line "󰖚" "Humidity   " "${humi}"
    print_line "󰓅" "Pressure   " "${pres}"

    sleep 600
done