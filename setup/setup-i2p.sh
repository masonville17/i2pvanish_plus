#!/bin/bash
echo "installing and configuring i2p"
wget "$I2P_DOWNLOAD_URL"
INSTALLER_PATH="/home/i2puser/$I2P_VERSION"
chmod +x $INSTALLER_PATH
sudo -u i2puser /usr/bin/expect <<EOF
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
sudo -u i2puser ./i2prouter start && sleep 10 && sudo -u i2puser ./i2prouter stop
sudo -u i2puser sed -i '/clientApp\.0\.args/c\clientApp.0.args=7657 0.0.0.0 ./webapps/' /home/i2puser/i2p/i2ptunnel.config
