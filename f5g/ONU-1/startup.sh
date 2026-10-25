#!/bin/sh

# IP ONU-1
/sbin/ip addr show eth0 | grep -q "10.70.1.2/30" || /sbin/ip addr add 10.70.1.2/30 dev eth0
/sbin/ip link set eth0 up

# Gateway hacia F5G-OLT
/sbin/ip route show | grep -q "^default via 10.70.1.1" || /sbin/ip route add default via 10.70.1.1

echo "ONU-1-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
