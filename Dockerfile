FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
    default-jdk \
    openvpn \
    sudo \
    ca-certificates \
    vim \
    expect \
    iproute2 \
    wget \
    unzip \
    iptables \
    dnsutils \
    net-tools && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY start.sh exclude_countries pass /app/
RUN chmod +x /app/start.sh
EXPOSE 7657 4445 4444

CMD ["./start.sh"]
