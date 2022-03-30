function newClient() {
	ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"

	for CLIENT_ID in {2..254}; do
		CLIENT_EXISTS=$(grep -c -E "^### client-${CLIENT_ID}\$" "/etc/wireguard/${SERVER_WG_NIC}.conf")
		if [[ ${CLIENT_EXISTS} == '0' ]]; then
			break
		fi
	done
	CLIENT_NAME="client-${CLIENT_ID}"

	for DOT_IP in {2..254}; do
		DOT_EXISTS=$(grep -c "${SERVER_WG_IPV4::-1}${DOT_IP}" "/etc/wireguard/${SERVER_WG_NIC}.conf")
		if [[ ${DOT_EXISTS} == '0' ]]; then
			break
		fi
	done


	BASE_IP=$(echo "$SERVER_WG_IPV4" | awk -F '.' '{ print $1"."$2"."$3 }')
	CLIENT_WG_IPV4="${BASE_IP}.${DOT_IP}"
	IPV4_EXISTS=$(grep -c "$CLIENT_WG_IPV4/24" "/etc/wireguard/${SERVER_WG_NIC}.conf")

	BASE_IP=$(echo "$SERVER_WG_IPV6" | awk -F '::' '{ print $1 }')
	CLIENT_WG_IPV6="${BASE_IP}::${DOT_IP}"
	IPV6_EXISTS=$(grep -c "${CLIENT_WG_IPV6}/64" "/etc/wireguard/${SERVER_WG_NIC}.conf")

	# Generate key pair for the client
	CLIENT_PRIV_KEY=$(wg genkey)
	CLIENT_PUB_KEY=$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)
	CLIENT_PRE_SHARED_KEY=$(wg genpsk)

	# Home directory of the user, where the client configuration will be written
	if [ -e "/home/${CLIENT_NAME}" ]; then
		# if $1 is a user name
		HOME_DIR="/home/${CLIENT_NAME}"
	elif [ "${SUDO_USER}" ]; then
		# if not, use SUDO_USER
		if [ "${SUDO_USER}" == "root" ]; then
			# If running sudo as root
			HOME_DIR="/root"
		else
			HOME_DIR="/home/${SUDO_USER}"
		fi
	else
		# if not SUDO_USER, use /root
		HOME_DIR="/root"
	fi

	# Create client file and add the server as a peer
	echo "[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128
DNS = ${CLIENT_DNS_1},${CLIENT_DNS_2}

[Peer]
PublicKey = ${SERVER_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
Endpoint = ${ENDPOINT}
AllowedIPs = 0.0.0.0/0,::/0" >> "${HOME_DIR}/${SERVER_WG_NIC}-${CLIENT_NAME}.conf"

		# Add the client as a peer to the server
        echo -e "\n### ${CLIENT_NAME}
[Peer]
PublicKey = ${CLIENT_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
AllowedIPs = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128" >> "/etc/wireguard/${SERVER_WG_NIC}.conf"

	wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")

	echo "${HOME_DIR}/${SERVER_WG_NIC}-${CLIENT_NAME}.conf"
}

source /etc/wireguard/params
newClient