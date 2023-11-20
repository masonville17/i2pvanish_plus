# i2p+ with Split-Tunnel OpenVPN

This Docker setup builds and starts an i2p+ service behind a split-tunnel OpenVPN connection, utilizing IpVanish as the VPN service.

## Features

- **i2p+ Service**: Run an enhanced version of the Invisible Internet Project (i2p) with additional features and improvements, installed fresh from universal jar file. i2psnark is included.
- **Split-Tunneling**: Local-only traffic is not sent through VPN, optimizing privacy and efficiency.
- **OpenVPN with IpVanish**: Secure and private connection using OpenVPN and IpVanish as the VPN service provider. Simply change the hardcoded download URI to use a different ovpn-compliant provider's config bundle.

## Configuration

You can customize the setup by filling out `exclude_countries` with any 2-letter country codes you'd like to remove from the downloaded `configs.zip` file. This allows for more control over the VPN configuration and server selection.

## Build Instructions

Build the Docker image using the following command:

```bash
docker build -t i2pvanishplus .
```
## Run Instructions

Run the Docker image using the following command:
```bash
docker run -p 7667:7667 --net=host  i2pvanishplus:latest
```

## Ports:
7667: local webservice port for i2p+ console / i2psnark
4444/4445: http/https local proxy ports for i2p network service

## Todo: 
need to parameterize everything and make it more generally useful and VPN service independent. I think this could be useful or convenient for someone. who uses i2p plus here and there as I do. If we make a few volume mounts for tunnels.conf and clients.conf or .i2p/i2p folders, i2psnark data, it could be more useful for general/development i2p use cases.

## Acknowledgments
This project is built upon the incredible work of the Invisible Internet Project (I2P) and the I2PPlus fork. A huge thanks to the developers and contributors of these projects for their dedication to privacy and internet freedom.

## Licensing and Usage
This project is free for non-commercial use. It is built upon open-source projects and inherits the permissions and restrictions of its underlying technologies. Please respect the licenses of the I2P and I2PPlus projects when using this software.