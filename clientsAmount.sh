source /etc/wireguard/params

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/wireguard/${SERVER_WG_NIC}.conf")
echo "${NUMBER_OF_CLIENTS}"
