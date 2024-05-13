#!/bin/bash

# Set the colors
CYAN='\033[0;96m'
YELLOW='\033[0;93m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine the width for each column
ID_WIDTH=13
NAME_WIDTH=30
STATE_WIDTH=8
PORTS_WIDTH=40

# Function to print a horizontal line with color to simulate a border
print_border_line () {
  printf "${YELLOW}+" # Start border color and left corner
  printf '%0.s-' $(seq 1 $ID_WIDTH) # Horizontal line for ID column
  #printf "+"
  printf '%0.s-' $(seq 1 $NAME_WIDTH) # Horizontal line for NAME column
  #printf "+"
  printf '%0.s-' $(seq 1 $STATE_WIDTH) #Horizontal line for STATE column
  #printf "+"
  printf '%0.s-' $(seq 1 $PORTS_WIDTH) # Horizontal line for PORTS column
  printf '%0.s-' $(seq 1 7) # Horizontal line for PORTS column
  printf "+${NC}\n" # Right corner and reset color
}

# Function to truncate or pad the string to a specific length
truncate_or_pad_string () {
  local str=$1
  local width=$2
  # Truncate and pad the string
  printf " %-$((${width}-1)).$((${width}-1))s " "$str"
}

print_state_with_color() {
  local state=$1
  if [ "$state" = "running" ]; then
    printf "%b" "${GREEN}$(truncate_or_pad_string $state $STATE_WIDTH)${NC}"
  else
    printf "%b" "${RED}$(truncate_or_pad_string $state $STATE_WIDTH)${NC}"
  fi
}


# Print the table with borders
print_border_line
printf "%b" "${YELLOW}|${NC}"
printf "%b" "${CYAN}$(truncate_or_pad_string 'CONTAINER ID' $ID_WIDTH)${NC}"
printf "%b" "${YELLOW}|${NC}"
printf "%b" "${CYAN}$(truncate_or_pad_string 'NAME' $NAME_WIDTH)${NC}"
printf "%b" "${YELLOW}|${NC}"
printf "%b" "${CYAN}$(truncate_or_pad_string 'STATE' $STATE_WIDTH)${NC}"
printf "%b" "${YELLOW}|${NC}"
printf "%b" "${CYAN}$(truncate_or_pad_string 'PORTS' $PORTS_WIDTH)${NC}"
printf "%b\n" "${YELLOW}|${NC}"
print_border_line

format_ports() {
  local ports=$1
  ports=$(printf "%s\n" "$ports" | tr ',' '\n')
  local line=""
  local hostSymbol="P"
  local containerSymbol="C"
  if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    hostSymbol="🌐"
    containerSymbol="🐋"
  fi
  for port in $ports; do
    if [[ $port == *":::"* ]]; then
      host=$(printf "%s\n" "$port" | awk -F '->' '{print $1}' | awk -F ':' '{print $NF}' | awk '{$1=$1};1')
      container=$(printf "%s\n" "$port" | awk -F '->' '{print $2}' | awk -F '/' '{print $1}' | awk '{$1=$1};1')
      line="${line}${hostSymbol}  ${host}: ${containerSymbol}  ${container}| "
    fi
  done
  line=$(printf "%s" "$line" | sed 's/ | $//')
  line=$(printf "%s" "$line" | sed 's/|$//')
  line=$(printf "%s" "$line" | sed 's/| $//')
  if [[ $(printf "%s" "$line" | tr -cd '|' | wc -c) -gt 1 ]]; then
    line=$(printf "%s" "$line" | awk -F '|' '{print $1"| "$2"| ..."}')
  else
    line=$(printf "%s" "$line" | awk -F '|' '{print $1" | "$2}')
  fi
  line=$(truncate_or_pad_string "$line" $PORTS_WIDTH)
  printf "%b" "$line"
}

# Use docker ps with --format to specify what information should be printed
docker ps -a  --format "{{.ID}}\t{{.Names}}\t{{.State}}\t{{.Ports}}" | sort -k2 | \
  while read -r id names state ports; do
    printf "%b" "${YELLOW}|${NC}"
    printf "%b" "$(truncate_or_pad_string $id $ID_WIDTH)"
    printf "%b" "${YELLOW}|${NC}"
    printf "%b" "$(truncate_or_pad_string "$names" $NAME_WIDTH)"
    printf "%b" "${YELLOW}|${NC}"
    print_state_with_color $state
    printf "%b" "${YELLOW}|${NC}"
    printf "%b" "$(format_ports "$ports")"
    printf "%b\n" "${YELLOW}|${NC}"
  done

print_border_line