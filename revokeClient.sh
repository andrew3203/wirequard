source /etc/wireguard/params
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/wireguard/${SERVER_WG_NIC}.conf")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
	echo "You have no existing clients!"
	exit 1
fi

CLIENT_NUMBER=$1
if [[ ${CLIENT_NUMBER} -g ${NUMBER_OF_CLIENTS} ]]; then
	echo "${CLIENT_NUMBER} no in (1, ${NUMBER_OF_CLIENTS})"
	exit 1
fi
	

CLIENT_NAME="client-${CLIENT_NUMBER}"

# remove [Peer] block matching $CLIENT_NAME
sed -i "/^### ${CLIENT_NAME}\$/,/^$/d" "/etc/wireguard/${SERVER_WG_NIC}.conf"

# remove generated client file
rm -f "${HOME}/${SERVER_WG_NIC}-${CLIENT_NAME}.conf"

# restart wireguard to apply changes
wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")
echo "${CLIENT_NAME}"



