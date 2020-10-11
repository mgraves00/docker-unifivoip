#!/bin/sh

RUNFLAG=1

do_term() {
	RUNFLAG=0
}

trap do_term TERM
 
if [ "$1" = "" ]; then
  /etc/init.d/unifi-voip start
  while [ $RUNFLAG -eq 1 ]; do
	  sleep 30
  done
  /etc/init.d/unifi-voip stop
else
  exec "$@"
fi
