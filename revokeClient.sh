function revokeClient() {
	NUMBER_OF_CLIENTS=$(grep -c -E "^### Client" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo "You have no existing clients!"
		exit 1
	fi

	NUMBER_OF_CLIENTS=$1

	# match the selected number to a client name
	CLIENT_NAME=$(grep -E "^### " "/etc/wireguard/${SERVER_WG_NIC}.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
    echo CLIENT_NAME

	# remove [Peer] block matching $CLIENT_NAME
	sed -i "/^### ${CLIENT_NAME}\$/,/^$/d" "/etc/wireguard/${SERVER_WG_NIC}.conf"

	# remove generated client file
	rm -f "${HOME}/${SERVER_WG_NIC}-${CLIENT_NAME}.conf"

	# restart wireguard to apply changes
	wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")
}

source /etc/wireguard/params
revokeClient