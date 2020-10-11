#
# Copyright (c) 2020, Michael Graves
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM ubuntu:latest as final

RUN apt update
RUN apt-get -y install binutils net-tools mongodb-server jsvc openjdk-8-jre-headless
COPY ${PWD}/unifi_voip_sysvinit_all.deb /tmp/unifi_voip_sysvinit_all.deb
RUN dpkg -i /tmp/unifi_voip_sysvinit_all.deb
RUN rm /tmp/unifi_voip_sysvinit_all.deb
RUN rm /usr/lib/unifi-voip/bin/mongod
COPY ${PWD}/mongod.sh /usr/lib/unifi-voip/bin/mongod
RUN chmod +x /usr/lib/unifi-voip/bin/mongod
COPY ${PWD}/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN rm /etc/init.d/unifi-voip
COPY ${PWD}/unifi-voip-init.sh /etc/init.d/unifi-voip
RUN chmod +x /etc/init.d/unifi-voip

# See https://help.ui.com/hc/en-us/articles/218506997-UniFi-Ports-Used
# 3478/udp STUN
# 9080/tcp http redirection
# 9443/tcp https GUI
# 10001/udp device discovery
# 1900/udp controller discover on local network
 
EXPOSE 9080/tcp 9443/tcp 10001/udp 3478/udp 1900/udp
VOLUME /data
 
ENTRYPOINT [ "/entrypoint.sh" ]

