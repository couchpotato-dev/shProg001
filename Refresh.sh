#!/bin/bash

# colors
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;35m'
nc='\033[0m'

# functions
function get() {
        local row=$1
        local col=$2
        free -h --giga | awk "NR==$row" | awk "{ print \$$col }"
}

function is_root() {
        if [ "$(id -u)" -ne 0 ]; then
                echo -e "$red[!] Permission Denied. Root required.$nc"
                exit 1
        fi
}

function refresh() {
        echo -en "$blue[*] Refreshing...$nc"
        if ! sudo sh -c 'echo 2 > /proc/sys/vm/drop_caches' 2>/dev/null; then
                echo -e "[ ${red}Failed$nc ] - Unable to drop caches. You may need root privileges."
        else
                echo -e "[ ${green}Success$nc ]"
        fi
}

function start_init() {
        echo -en "$blue[*] Starting"
        for i in $(seq 1 2); do
                echo -n "."
                sleep 1
        done
        echo -e "$nc[ ${green}Success$nc ]"
}

function PRINT() {
        local row=$1
        local col=$2
        echo -e "${green}$(get $row $col)$yellow"
}

function details() {
        sleep 1
        echo -e "$yellow|=========================|"
        echo "|       System Info       |"
        echo "|=========================|"
        echo ""
        echo "::::::::::::::::::::::::::::::"
        echo -e "[*] Total Memory\t: $(PRINT 2 2)"
        echo -e "[*] Total Swap\t\t: $(PRINT 3 2)"
        echo -e "[*] Memory in use\t: $(PRINT 2 3)"
        echo -e "[*] Swap in use\t\t: $(PRINT 3 3)"
        echo -e "[*] Free Memory\t\t: $(PRINT 2 4)"
        echo -e "[*] Free Swap\t\t: $(PRINT 3 4)"
        echo ""
}

function single() {
        start_init
        refresh
        details
}

function loop() {
        while true; do
                clear
                single
                sleep 3
                echo -e "[*] Press Ctrl + C to exit$nc"
        done
}

function main() {
        local prop=$1
        if [ -z "$prop" ]; then
                echo -e "$red[!] Usage: Refresh <property>$nc"
                echo -e "$yellow\t[+] Single\t: S"
                echo -e "$yellow\t[+] Loop\t: L$nc"
                exit 1
        fi

        choice="${prop,,}"
        case $choice in
                s)
                        single
                        ;;
                l)
                        loop
                        ;;
                *)
                        echo -e "$red[!] Invalid Input. Aborting...$nc"
                        exit 1
                        ;;
        esac
}

is_root
main $1
