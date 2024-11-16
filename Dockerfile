FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV VPN_INTERFACE="$VPN_INTERFACE:-tun0"
ENV OPENVPN_CONFIGS_ZIP_URL="$OPENVPN_CONFIGS_ZIP_URL:-https://configs.ipvanish.com/configs/configs.zip"
ENV I2P_USER_HOMEDIR="$I2P_USER_HOMEDIR:-/home/i2puser"
ENB I2P_USER_CONFIG_FILES="$I2P_USER_CONFIG_FILES/*.config)"
# get i2p version, download url, 
WORKDIR /app
COPY ./setup/* .
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
    apt-get clean && \
        I2P_VERSION=${I2P_VERSION:-$(curl -s https://i2pplus.github.io/ | grep -oP 'i2pinstall_\K[0-9]+\.[0-9]+\.\d+\+' | head -n 1)} && \
            echo "Resolved I2P_VERSION=$I2P_VERSION" && \
        I2P_DOWNLOAD_URL "https://i2pplus.github.io/installers/i2pinstall_${I2P_VERSION}.exe" > /tmp/i2p_download_url && \
        export I2P_VERSION && \
        chmod +x start.sh && \
            /bin/bash -c "start.sh"

EXPOSE 7657 7667 4445 4444

CMD ["./start.sh"]
