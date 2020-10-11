#!/bin/sh

# Copyright (C) 2020 by Michael Graves <mgraves+github@brainfat.net>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
# OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
  docker volume create unifivoip
  docker run -p 1900:1900/udp -p 3478:3478/udp -p 9080:9080/tcp -p 9443:9443/tcp -p 10001:10001/udp -v unifivoip:/data -d unifivoip:$VER
EOF
