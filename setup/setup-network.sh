#!/bin/bash
ORIGINAL_EXTERNAL_IP="$(curl -s https://ipinfo.io/ip)"

# Local ports to exclude from VPN
echo "Adding iptable rules"
iptables -A OUTPUT -o tun0 -p tcp --dport 7657 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4445 -j DROP
iptables -A OUTPUT -o tun0 -p tcp --dport 4444 -j DROP
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE






if [ ${#config_files[@]} -gt 0 ] && [ -e "${config_files[0]}" ]; then
    for file in "${config_files[@]}"; do
        echo "Copying user-defined config file $file..."
        cp "$file" /home/i2puser/i2p/
    done
else
    echo "No user-specified .config files found in $config_dir. Skipping copy."
fi

while true; do
    vpn_infos=$(ps -f -p $vpn_pid)
    i2pinfos=$(sudo -u i2puser ./i2prouter start)
    ip_addr=$(curl -s https://ipinfo.io/ip)
    ip_addr_infos="You are using $ip_addr as your external IP address (originally $ORIGINAL_EXTERNAL_IP)..."    
    echo "vpn infos: PID: $vpn_pid, vpn_infos... i2p info: $i2pinfos... ipinfos: $ip_addr_infos... Sleeping 10m..."
    sleep 600
done
trap "kill $vpn_pid" EXIT
