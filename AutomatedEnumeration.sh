#!/usr/bin/bash
echo '-----Automated Enumeration-----'
if [ $# -eq 0 ]
    then echo -e '\e[33mUsage: ./AutomatedEnumeration.sh xx.xx.xx.xx'
    exit
fi
echo 'Target IP address/host: '$1
if ping -c 1 -W 1 >/dev/null $1
    then echo  -e '\e[32mHost is up. Starting initial Host enumeration...'
    else echo  -e '\e[31mHost is down'; exit
fi  
if nmap -sC -sV -oN nmap.txt $1
    then  cat nmap.txt
    PING = $true
    else  echo -e '\e33mHost does not accept pings, using option -Pn'
    nmap -sC -sV -oN nmap.txt $1 -Pn
    PING = $false
fi
echo -e '\e[32Results saved to nmap.txt'
echo -e '\e[32Initial enumeration completed(First 1000 Ports), Starting full scan in the background'
if $PING
    then nmap -sC -sV -oN nmap.txt $1 -p- &  > fullnmap.txt
    else nmap -sC -sV -oN nmap.txt $1 -Pn -p- & > fullnmap.txt
fi
ls
