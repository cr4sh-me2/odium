start_ngrok(){

printf "[*] Starting ngrok...\n"
ngrok tcp 4444 > /dev/null &
while ! nc -z localhost 4040; do
  printf "[*] Waiting for ngrok url...\n"
  sleep 1.5 
done

NGROK_REMOTE_URL="$(curl -s http://localhost:4040/api/tunnels | jq ".tunnels[0].public_url")"

if test -z "${NGROK_REMOTE_URL}"
then
  printf "[!] Ngrok returned invail url (${NGROK_REMOTE_URL})\n"
  exit 1
fi

NGROK_REMOTE_HOSTNAME="$(printf $NGROK_REMOTE_URL | awk -F "//" '{print $2}' | awk -F ":" '{print $1}')"
NGROK_REMOTE_PORT="$(printf $NGROK_REMOTE_URL | awk -F ":" '{print $3}')"

printf "URL: $NGROK_REMOTE_URL\n"
printf "HOSTNAME: $NGROK_REMOTE_HOSTNAME\n"
printf "PORT: $NGROK_REMOTE_PORT\n"

}

stop_ngrok(){

    printf "[*] Stopping ngrok in 5s...\n"
    sleep 5
    kill -9 $(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $2}')
    printf "[i] Done!\n"

}

start_ngrok
stop_ngrok