FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV VPN_INTERFACE="$VPN_INTERFACE:-tun0"
ENV OPENVPN_CONFIGS_ZIP_URL="$OPENVPN_CONFIGS_ZIP_URL:-https://configs.ipvanish.com/configs/configs.zip"
ENV I2P_USER="i2puser"
ENV I2P_USER_HOMEDIR="/home/$I2P_USER"
ENV I2P_USER_CONFIG_FILES="$I2P_USER_HOMEDIR/*.config"
ENV USER_SETUP_PARAMS="sed -i '/clientApp\.0\.args/c\clientApp.0.args=7657 0.0.0.0 ./webapps/' /home/$I2P_USER/i2p/i2ptunnel.config"
# get i2p version, download url, 
WORKDIR /app
COPY docker-entrypoint.sh ./ 
COPY setup/* ./
# get i2p dependencies
RUN apt-get update && \
        apt-get install -y \
        default-jdk \
        openvpn \
        sudo \
        procps \
        ca-certificates \
        vim \
        expect \
        iproute2 \
        curl \
        wget \
        unzip \
        iptables \
        dnsutils \
        net-tools && \
    apt-get clean

RUN export I2P_VERSION=${I2P_VERSION:-$(curl -s https://i2pplus.github.io/ | grep -oP 'i2pinstall_\K[0-9]+\.[0-9]+\.\d+\+' | head -n 1)} && \
    export I2P_DOWNLOAD_URL="https://i2pplus.github.io/installers/i2pinstall_${I2P_VERSION}.exe" && \
    echo "$(printenv)" > /app/.prefs

RUN echo "beginning environment setup." && \
    chmod +x .prefs && \
    chmod +x ./docker-entrypoint.sh && \
    chmod +x ./setup-user.sh && \
    chmod +x ./setup-openvpn.sh && \
    chmod +x ./setup-i2p.sh

RUN /bin/bash -c "/app/setup-user.sh"

RUN /bin/bash -c "/app/setup-openvpn.sh"

RUN /bin/bash -c "/app/setup-i2p.sh"

EXPOSE 7657 7667 4445 4444

ENTRYPOINT [ "/bin/bash", "-c", "docker-entrypoint.sh" ]
