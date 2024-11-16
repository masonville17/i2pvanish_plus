#!/bin/bash
# download and inflate, remove zipfile and exclude countries
wget "$OPENVPN_CONFIGS_ZIP_URL" && unzip *.zip && rm *.zip
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
export vpn_pid=$!

sleep 5
if ip a show tun0 up > /dev/null 2>&1; then
    echo "VPN is connected."
else
    echo "VPN connection failed."
    exit 1
fi