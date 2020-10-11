#!/bin/sh

FILE=unifi_voip_sysvinit_all.deb
VER=1.0.5

if [ ! -f $FILE ]; then
	echo "Please download the 'Unifi VoIP Controller v1.0.5 for Linux' from https://ui.com/download/unifi-voip"
#	curl -o $FILE https://dl.ui.com/unifi-voip/1.0.5-kxe7d9/unifi_voip_sysvinit_all.deb
	exit 1
fi

docker build --tag "unifivoip:$VER" .

cat << EOF
To start application do
  docker run -p 1900:1900/udp -p 3478:3478/udp -p 9080:9080/tcp -p 9443:9443/tcp -p 10001:10001/udp --mount type=bind,source="\$(pwd)"/localdata,target=/data -d unifivoip:$VER
EOF
