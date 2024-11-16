#!/bin/bash
echo "installing and configuring i2p"
wget "$I2P_DOWNLOAD_URL"
INSTALLER_PATH="/home/$I2P_USER/$I2P_VERSION"
chmod +x $INSTALLER_PATH
sudo -u $I2P_USER /usr/bin/expect <<EOF
spawn java -jar $INSTALLER_PATH -console
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect "Select target path"
send "$I2P_USER_HOMEDIR/i2p\r"
expect "press 1 to continue, 2 to quit, 3 to redisplay"
send "1\r"
expect eof
EOF

cd "$I2P_USER_HOMEDIR/i2p"
echo "Updating I2p configuration"
sudo -u "$I2P_USER" ./i2prouter start && sleep 10 && sudo -u "$I2P_USER" ./i2prouter stop
eval "$(sudo -u "$I2P_USER" "$USER_SETUP_PARAMS") "

if [ ${#I2P_USER_CONFIG_FILES[@]} -gt 0 ] && [ -e "${I2P_USER_CONFIG_FILES[0]}" ]; then
    for file in "${I2P_USER_CONFIG_FILES[@]}"; do
        echo "Copying user-defined config file $file..."
        cp "$file" /home/$I2P_USER/i2p/
    done
else
    echo "No user-specified .config files found in $I2P_USER_CONFIG_FILES. Skipping copy."
fi