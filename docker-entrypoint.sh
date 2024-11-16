#!/bin/bash

ORIGINAL_EXTERNAL_IP="$(curl -s https://ipinfo.io/ip)"

# Local ports to exclude from VPN
echo "Adding iptable rules"
iptables -A OUTPUT -o tun0 -p tcp --dport 7657 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4445 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4444 -j DROP
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

# select random ovpn file and establish connection
OVPN_FILE=$(find . -name "*.ovpn" | shuf -n 1)
echo "Establishing Connection with $OVPN_FILE"
sed -i '/keysize/d' "${OVPN_FILE}"

openvpn --config "${OVPN_FILE}" --auth-user-pass pass & 
export OPENVPN_PID=$!

sleep 5
if ip a show tun0 up > /dev/null 2>&1; then
    echo "VPN is connected."
else
    echo "VPN connection failed."
    exit 1
fi

while true; do
    vpn_infos=$(ps -f -p $OPENVPN_PID)
    i2pinfos=$(sudo -u $I2P_USER ./i2prouter start)
    
    EXTERNAL_IP_ADDRESS=$(curl -s https://ipinfo.io/ip)
    EXTERNAL_IP_ADDRESS_infos="You are using $EXTERNAL_IP_ADDRESS as your external IP address (originally $ORIGINAL_EXTERNAL_IP)..."    
    echo "vpn infos: PID: $OPENVPN_PID, vpn_infos... i2p info: $i2pinfos... ipinfos: $EXTERNAL_IP_ADDRESS_infos... Sleeping 10m..."
    sleep 600
done
trap "kill $OPENVPN_PID" EXIT