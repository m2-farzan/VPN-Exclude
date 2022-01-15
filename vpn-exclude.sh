#!/bin/bash

# Check dependencies [dnsutils, zenity]
command -v zenity || ( echo "Please install zenity first."; exit 1 )
command -v dig || ( zenity --error --width 200 --text "Please install dnsutils first."; exit 1 )

# Define regex patterns
IP_REGEX="\d+\.\d+\.\d+\.\d"
RANGE_REGEX="\d+\.\d+\.\d+\.\d\/\d+"
DOMAIN_REGEX="(\w+\.)+\w+"

# Create or load config file
CONFIG_ROOT_DIR="$HOME/.config/vpn-exclude"
LAST_HOSTS_FILE="$CONFIG_ROOT_DIR/last_hosts.txt"
mkdir -p "$CONFIG_ROOT_DIR"
touch "$LAST_HOSTS_FILE"

# Ask for hosts
HOSTS=`cat "$LAST_HOSTS_FILE" | zenity --text-info --editable --title "Hosts to exclude"`
if [[ -z "$HOSTS" ]]; then
    exit 0
fi
echo "$HOSTS" > "$LAST_HOSTS_FILE"

# Translate domains to IP's
IPs=""
for line in $HOSTS
do
    if [[ ! -z `echo "$line" | grep -oP "$RANGE_REGEX"` ]]
    then
        IPs="$IPs $line"
    elif [[ ! -z `echo "$line" | grep -oP "$IP_REGEX"` ]]
    then
        IPs="$IPs $line"
    elif [[ ! -z `echo "$line" | grep -oP "$DOMAIN_REGEX"` ]]
    then
        IPs="$IPs `dig +short $line`"
    fi
done

# Find network interface and non-tunneled gateway
NET_DEVICE=`ip route show | grep '^default' | grep -oP "dev [w|e]\w+" | cut -d' ' -f2`
GATEWAY=`ip route show | grep '^default' | grep -P "dev [w|e]\w+" | grep -oP "$IP_REGEX"`
echo "NET_DEVICE is $NET_DEVICE"
echo "GATEWAY is $GATEWAY"

# Generate routing commands
ROUTE_COMMANDS=""
CMD=${1:-"add"}
for IP in $IPs
do
    echo "$IP"
    ROUTE_COMMANDS="$ROUTE_COMMANDS ip route $CMD $IP via $GATEWAY dev $NET_DEVICE;"
done

# Apply routing
command -v gksu;
if [[ $? -eq 0 ]]; then
    RESULT=`gksu "bash -c '$ROUTE_COMMANDS'" 2>&1 >/dev/null`
else
    RESULT=`zenity --title 'Sudo password' --password | sudo -S bash -c "$ROUTE_COMMANDS" 2>&1 >/dev/null`
fi

# Report errors if any
ERROR=""

echo $RESULT
while IFS= read -r line; do
    if [[ ! -z `echo "$line" | grep -oP "^Error"` ]]; then
        ERROR_CAUSE=`echo "$line" | grep -oP "($RANGE_REGEX\b)|($IP_REGEX\b)|($DOMAIN_REGEX\b)"`
        if [[ ! -z $ERROR_CAUSE ]]; then
            ERROR="${ERROR} $ERROR_CAUSE"
        else
            ERROR="${ERROR}\nError: $line"
        fi
    fi
done <<< "$RESULT"

if [[ ! -z "${ERROR}" ]]; then
    notify-send "VPN Exclude | Failed Domains:" "${ERROR}"
else
    notify-send --hint int:transient:1 "VPN Exclude" "Routes were applied." --expire-time=3000
fi
