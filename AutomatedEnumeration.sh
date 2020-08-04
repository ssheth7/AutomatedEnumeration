#!/usr/bin/bash
echo '         -----Automated Enumeration-----'
if [ $# -eq 0 ]
    then echo -e '\e[33mUsage: ./AutomatedEnumeration.sh xx.xx.xx.xx';
    echo  'or'
    echo -e '\e[33mUsage: ./AutomatedEnumeration.sh domain'
    exit
fi
echo 'Target IP address/host: '$1
if ping -c 1 -W 1 >/dev/null $1
    then echo  -e '\e[32mHost is up. Starting initial Host enumeration...\e[37m'
    else echo  -e '\e[31mHost is down\e[37m'; exit
fi  
if [ ! -f './nmap.txt' ];
then if nmap -sC -sV -oN nmap.txt $1
    then  cat nmap.txt
    else  echo -e '\e33mHost does not accept pings, using option -Pn'
    nmap -sC -sV -oN nmap.txt $1 -Pn
    fi
fi
echo -e '\e[32mResults saved to nmap.txt'
echo -e '\e[32mInitial enumeration completed(First 1000 Ports)...\e[37m'
PORTLIST=$(cat nmap.txt | tail -n +6 | head -n -3 |  grep '^[0-9]') 
#declare -a myArray
myArray=($PORTLIST)
echo "${PORTLIST[@]}"

