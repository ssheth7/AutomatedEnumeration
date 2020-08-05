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
if [ ! -f './nmap.txt' ]; then 
if nmap -sC -sV -oN nmap.txt $1
    then  cat nmap.txt
    else  echo -e '\e33mHost does not accept pings, using option -Pn'
    nmap -sC -sV -oN nmap.txt $1 -Pn
    fi
fi
echo -e '\e[32mResults saved to nmap.txt'
echo -e '\e[32mInitial enumeration completed(First 1000 Ports)...\e[37m'
#Formats nmap output into array
PORTLISTSTR=$(cat nmap.txt | tail -n +6 | head -n -3 |  grep '^[0-9]') 
NUM=$(echo "${PORTLISTSTR[@]}" | wc -l )
PORTLIST=()
for (( i = 1; i <= $NUM; i++ ))
do 
    if [ $(echo "${PORTLISTSTR[@]}" | sed -n "${i}p" | awk {'print $2'}) == "open" ]; then
    echo "${PORTLISTSTR[@]}" | sed -n "${i}p" | awk {'print $1 "\t" $3'}
    PORTLIST+=($( echo "${PORTLISTSTR[@]}" | sed -n "${i}p" | awk {'print $1 "\t" $3'}))
    fi
done 
echo Debugging: "${PORTLIST[@]}"
echo -e '\e[32mEnumerable Ports\e[37m'
CMD=()
((NUM*=2))
for (( i = 1; i <= $NUM; i+=2 )) 
do
    PORTLIST[$i-1]=$(echo "${PORTLIST[$i-1]}" | grep -Eo '[0-9]+')
    echo Service: "${PORTLIST[$i]}" running on port "${PORTLIST[$i-1]}"
    case ${PORTLIST[$i]} in
    ssh)
        printf '\e[33m  Bruteforcable - Example: hydra -L users.txt -P passwords.txt ssh://' && printf "$1:" && printf "${PORTLIST[$i-1]}" | grep -Eo '[0-9]{1,"}';printf '\n%s\e[37m'
    ;;
    ftp)
        if curl ftp://10.10.10.187/* --user anonymous:anonymous -s
        then
            printf '  \e[32Anonymous Access allowed\e[37m\n'
        else 
            printf '  \e[31mAnonymous Access denied. No files found.\e[37m\n'
        fi
    ;;
    http)
        printf '\e[32m  Enumerable with gobuster \e[37m\n'
        CMD+=("gobuster dir -u http://$1:${PORTLIST[$i-1]} -q -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -o ./gobusterp:${PORTLIST[$i-1]}.txt 1&>/dev/null ")
    ;;
    esac
done
printf '\e[32mEnumerating through nmap results!\e[37m\n'
for (( i = 0; i < ${#CMD[@]}; i++))
do 
    echo ${CMD[$i]}
    eval ${CMD[$i]}
done
exit

