Docker build script for UniFi VoIP service.

Once image is created start service by:

``docker run -p 1900:1900/udp
     -p 3478:3478/udp
     -p 9080:9080/tcp
     -p 9443:9443/tcp
     -p 10001:10001/udp
     --mount type=bind,source="$(pwd)"/localdata,target=/data
     -d unifivoip:1.0.5
``
