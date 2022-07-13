tcp_host=$(curl -s localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url" | awk -F "//" '{print $2}' | awk -F ":" '{print $1}')
tcp_port=$(curl -s localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url" | awk -F ":" '{print $3}')

printf "HOST: $tcp_host PORT: $tcp_port\n"