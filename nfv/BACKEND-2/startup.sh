#!/bin/sh

# IP de BACKEND-2
/sbin/ip addr show eth0 | grep -q "10.62.0.12/24" || /sbin/ip addr add 10.62.0.12/24 dev eth0
/sbin/ip link set eth0 up

# Gateway hacia VNF-LOADBALANCER
/sbin/ip route show | grep -q "^default via 10.62.0.1" || /sbin/ip route add default via 10.62.0.1

# Servidor web
pgrep -x httpd >/dev/null 2>&1 || httpd -f -p 80 -h /www >/opt/netcloud/httpd.log 2>&1 &

echo "BACKEND-2-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
