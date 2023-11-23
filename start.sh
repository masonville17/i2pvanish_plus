#!/bin/bash
VPN_INTERFACE="tun0"
OPENVPN_CONFIGS_ZIP_URL="https://configs.ipvanish.com/configs/configs.zip"
I2P_VERSION="i2pinstall_2.3.0+.exe"

# Local ports to exclude from VPN
echo "Adding iptable rules"
iptables -A OUTPUT -o tun0 -p tcp --dport 7657 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4445 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4444 -j DROP
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

# downloading and configuring openvpn files / connection

# download and inflate, remove zipfile and exclude countries
wget $OPENVPN_CONFIGS_ZIP_URL && unzip *.zip && rm *.zip
readarray -t countries < exclude_countries
for country in "${countries[@]}"
do
    echo "Removing files with pattern *-$country-*"
    rm -rf *-"$country"-*
done

# select random ovpn file and establish connection
OVPN_FILE=$(find . -name "*.ovpn" | shuf -n 1)
echo "Establishing Connection with $OVPN_FILE"
sed -i '/keysize/d' "${OVPN_FILE}"
openvpn --config "${OVPN_FILE}" --auth-user-pass pass & 
vpn_pid=$!

# Wait for VPN to establish connection and check if connection is established
sleep 20
if ip a show tun0 up > /dev/null 2>&1; then
    echo "VPN is connected."
else
    echo "VPN connection failed."
    exit 1
fi


# Add non-root user and switch to it
useradd -m i2puser
cd /home/i2puser

echo "installing and configuring i2p"
wget http://i2pplus.github.io/installers/$I2P_VERSION
INSTALLER_PATH="/home/i2puser/$I2P_VERSION"
chmod +x $INSTALLER_PATH

sudo -u i2puser /usr/bin/expect <<EOF
spawn java -jar $INSTALLER_PATH -console
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect "Select target path"
send "/home/i2puser/i2p\r"
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect eof
EOF

cd /home/i2puser/i2p
sudo -u i2puser ./i2prouter start && sleep 10 && sudo -u i2puser ./i2prouter stop
echo "updating i2p config"

sudo -u i2puser sed -i '/clientApp\.0\.args/c\clientApp.0.args=7657 0.0.0.0 ./webapps/' /app/i2p/i2ptunnel.config

while true; do
    vpn_infos=$(ps -f -p $vpn_pid)
    i2pinfos=$(sudo -u i2puser ./i2prouter start)
    ipinfos=$(ip a)
    echo "vpn infos: PID: $vpn_pid, vpn_infos... i2p info: $i2pinfos... ipinfos: $ipinfos... Sleeping 10m..."
    sleep 600
done
trap "kill $vpn_pid" EXIT
