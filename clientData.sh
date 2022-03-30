source /etc/wireguard/params
CLIENT_NUMBER=$1
echo `grep -E "^### " "/etc/wireguard/${SERVER_WG_NIC}.conf"` >> active_clients.txt
echo 'active_clients.txt'
a=$(grep -E "^PublicKey = " "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -f 3 | sed -n "${CLIENT_NUMBER}"p)
echo "${a[@]:12}"