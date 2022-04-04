source /etc/wireguard/params
echo `grep -E "^### " "/etc/wireguard/${SERVER_WG_NIC}.conf"` > active_clients.txt
echo 'active_clients.txt'