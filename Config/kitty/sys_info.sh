#!/usr/bin/env bash

WHITE='\033[38;2;255;255;255m'
GRAY='\033[38;2;176;176;176m'
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

  echo -e "${WHITE}${BOLD}SYSTEM${NC}"
  echo "----------------------"

  printf "${BOLD}${GRAY}CPU${NC}  %-3s%%   %3s°C\n" "$CPU_USAGE" "$CPU_TEMP"
  printf "${BOLD}${GRAY}GPU${NC}  %-3s%%   %3s°C\n" "$GPU_USAGE" "$GPU_TEMP"
  printf "${BOLD}${GRAY}RAM${NC}  %-5s  %3s%%\n" "$RAM_USED" "$RAM_PERCENT"
  printf "${BOLD}${GRAY}MBD${NC} %3s°C\n" "$MB_TEMP"

  echo "----------------------"

  sleep 2
done
