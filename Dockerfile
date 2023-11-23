FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
    default-jdk \
    openvpn \
    tor \
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
EXPOSE 7657 4445 4444
RUN useradd -m i2puser && \
    chown -R i2puser:i2puser /app

USER i2puser

COPY --chown=i2puser:i2puser start.sh exclude_countries pass /app/
RUN chmod +x /app/start.sh

CMD ["./start.sh"]
