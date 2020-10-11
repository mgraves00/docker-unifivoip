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

