#!/usr/bin/bash
#Todo: filter /tcp from ports, get command array working
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
#declare -a myArray
myArray=($PORTLISTSTR)
NUM=$(echo "${PORTLISTSTR[@]}" | wc -l )
for i in $NUM
do  
    PORTLIST=($( echo "${PORTLISTSTR[@]}" | head -n $NUM | awk {'print $1 "\t" $3'}))
done 
echo "${PORTLIST[@]}"
echo -e '\e[32mEnumerable Ports\e[37m'
((NUM++))
CMD=()
for (( i = 1; i <= $NUM; i+=2 )) 
do
    echo Service: "${PORTLIST[$i]}" running on port "${PORTLIST[$i-1]}"
    case ${PORTLIST[$i]} in
    ssh)
        printf '\e[33m  Bruteforcable - Example: hydra -L users.txt -P passwords.txt ssh://' && printf "$1:" && printf "${PORTLIST[$i-1]}" | grep -Eo '[0-9]{1,4"}';printf '\n%s\e[37m'
    ;;
    ftp)
        printf '  FTP found'
        $CMD+="curl ftp://$1/* --user anonymous:anonymous"
    ;;
    http)
        printf '\e[32m  Enumerable with gobuster\n'
        CMD+=("gobuster dir -u http://$1:${PORTLIST[$i-1]} -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt")
    ;;
    esac
done
echo $CMD
exit

