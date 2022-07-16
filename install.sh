if [[ $EUID -ne 0 ]]; then
   printf "\n\e[0m[\e[91m!\e[0m] THIS SCRIPT MUST BE RUN AS ROOT! ABORTING...\n" 
   exit 1
fi

ngrok_setup(){

curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/#
sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok

printf "\n\e[0m[\e[93m?\e[0m] Input your ngrok authtoken below \n" && read -p "-> " authtoken

ngrok config add-authtoken $authtoken

printf "\n\e[0m[\e[92mi\e[0m] Ngrok setup done! \n"

}

printf "
<---------- ODIUM INSTALLER ---------->

"

sudo apt update

info='\n\e[0m[\e[92mi\e[0m] INSTALLING TOOL...\n'

command -v jq >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install jq -y; }
command -v msfconsole >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install metasploit-framework -y; }
command -v ngrok >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; ngrok_setup; }

