#!/bin/bash
VPN_INTERFACE="tun0"

wget https://configs.ipvanish.com/configs/configs.zip
unzip configs.zip
rm configs.zip

readarray -t countries < exclude_countries

for country in "${countries[@]}"
do
    echo "Removing files with pattern *-$country-*"
    rm -rf *-"$country"-*
done

OVPN_FILE=$(find . -name "*.ovpn" | shuf -n 1)
echo "Today, we'll connect to $OVPN_FILE"

sed -i '/keysize/d' "${OVPN_FILE}"

sleep 5
echo "vpn should be connected by now."
ip a
sleep 15
# Local ports to exclude from VPN
iptables -A OUTPUT -o tun0 -p tcp --dport 7657 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4445 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4444 -j DROP
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

echo "installing and configuring i2p"

mkdir ./i2p && cd ./i2p

wget http://i2pplus.github.io/installers/i2pinstall_2.3.0+.exe
INSTALLER_PATH="./i2pinstall_2.3.0+.exe"
chmod +x $INSTALLER_PATH

/usr/bin/expect <<EOF
spawn java -jar $INSTALLER_PATH -console
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect "Select target path"
send "/app/i2p\r"
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect eof
EOF

chmod +x i2prouter
./i2prouter start
sleep 10
./i2prouter stop

echo "updating i2p config"

sed -i '/clientApp\.0\.args/c\clientApp.0.args=7657 0.0.0.0 ./webapps/' /app/i2p/i2ptunnel.config

while true; do
    i2pinfos=$(./i2prouter start)
    ipinfos=$(ip a)
    echo "i2p info: $i2pinfos... ipinfos: $ipinfos... Sleeping 10m..."
    sleep 600
done
wait
