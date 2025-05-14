#!/bin/bash
#

NS=''
NS1=''
NS2=''
NS3=''
NS4=''
NS5=''
NS6='ns-dang.raf22.site'
A='phc.jericoo.site'

LOOP_DELAY=0

# Added all requested IP addresses
declare -a HOSTS=(
    '124.6.181.31'
    '124.6.181.171'
    '124.6.181.26'
    '124.6.181.27'
    '124.6.181.25'
)

network_booster() {
    echo "Starting network booster..."
    while true; do
        for host in "${HOSTS[@]}"; do
            ping -c 1 "${host}" >/dev/null &
        done
        wait
    done
}

###################################
VER=1.0
if ! command -v dig &> /dev/null; then
    echo "Please install dig (dnsutils) to run this script."
    exit 1
fi

endscript() {
    unset NS NS1 NS2 NS3 NS4 NS5 NS6 A LOOP_DELAY HOSTS
    exit 1
}

trap endscript 2 15

check() {
    for host in "${HOSTS[@]}"; do
        for R in "${A}" "${NS}" "${NS1}" "${NS2}" "${NS3}" "${NS4}" "${NS5}" "${NS6}"; do
            # Skip empty resolver names
            if [ -z "$R" ]; then
                continue
            fi
            
            if [ -z "$(dig "@${host}" "${R}")" ]; then
                echo -e "\e[31mFailed - Querying: ${R} from ${host}\e[0m"
            else
                echo -e "\e[32mSuccess - Querying: ${R} from ${host}\e[0m"
            fi
        done
    done
}

echo -e "DNS List: [\e[1;34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"

if (( LOOP_DELAY == 1 )); then
    LOOP_DELAY=$((LOOP_DELAY + 1))
fi

# Always run in loop mode regardless of parameters
echo "Script loop: ${LOOP_DELAY} seconds"
network_booster & # Start the network booster in the background
NETWORK_BOOSTER_PID=$!

# Ensure cleanup of background process on exit
trap 'kill $NETWORK_BOOSTER_PID 2>/dev/null; endscript' 2 15

while true; do
    check
    echo '-----------------------------------------'
    sleep "${LOOP_DELAY}"
done

exit 0
