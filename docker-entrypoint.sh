#!/bin/bash

# select random ovpn file and establish connection
OVPN_FILE=$(find . -name "*.ovpn" | shuf -n 1)
echo "Establishing Connection with $OVPN_FILE"
sed -i '/keysize/d' "${OVPN_FILE}"

openvpn --config "${OVPN_FILE}" --auth-user-pass pass & 
export vpn_pid=$!

sleep 5
if ip a show tun0 up > /dev/null 2>&1; then
    echo "VPN is connected."
else
    echo "VPN connection failed."
    exit 1
fi

while true; do
    vpn_infos=$(ps -f -p $vpn_pid)
    i2pinfos=$(sudo -u $I2P_USER ./i2prouter start)
    ip_addr=$(curl -s https://ipinfo.io/ip)
    ip_addr_infos="You are using $ip_addr as your external IP address (originally $ORIGINAL_EXTERNAL_IP)..."    
    echo "vpn infos: PID: $vpn_pid, vpn_infos... i2p info: $i2pinfos... ipinfos: $ip_addr_infos... Sleeping 10m..."
    sleep 600
done
trap "kill $vpn_pid" EXIT