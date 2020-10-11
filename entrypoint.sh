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

# NOTE: should not exceed the docker TERM time
SLEEPTIME=30
RUNFLAG=1

do_term() {
	RUNFLAG=0
}

trap do_term TERM
 
if [ "$1" = "" ]; then
  /etc/init.d/unifi-voip start
  while [ $RUNFLAG -eq 1 ]; do
	  sleep $SLEEPTIME
  done
  /etc/init.d/unifi-voip stop
else
  exec "$@"
fi
