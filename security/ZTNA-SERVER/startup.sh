#!/bin/sh

/sbin/ip addr show eth0 | grep -q "10.80.0.10/24" || /sbin/ip addr add 10.80.0.10/24 dev eth0
/sbin/ip link set eth0 up

/sbin/ip route show | grep -q "^default via 10.80.0.1" || /sbin/ip route add default via 10.80.0.1

pgrep -x httpd >/dev/null 2>&1 || httpd -f -p 80 -h /www >/opt/netcloud/httpd.log 2>&1 &

echo "ZTNA-SERVER-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
