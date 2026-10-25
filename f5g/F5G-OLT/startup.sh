#!/bin/sh

# ONU-1
/sbin/ip addr show eth0 | grep -q "10.70.1.1/30" || /sbin/ip addr add 10.70.1.1/30 dev eth0
/sbin/ip link set eth0 up

# ONU-2
/sbin/ip addr show eth1 | grep -q "10.70.2.1/30" || /sbin/ip addr add 10.70.2.1/30 dev eth1
/sbin/ip link set eth1 up

# Uplink hacia N6
/sbin/ip addr show eth2 | grep -q "10.60.0.20/24" || /sbin/ip addr add 10.60.0.20/24 dev eth2
/sbin/ip link set eth2 up

# Routing
echo 1 > /proc/sys/net/ipv4/ip_forward

/sbin/ip route show | grep -q "^default via 10.60.0.1" || /sbin/ip route add default via 10.60.0.1

echo "F5G-OLT-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# DBA base: 20 Mbit/s por ONU
/sbin/tc qdisc replace dev eth0 root tbf rate 20mbit burst 32kbit latency 400ms
/sbin/tc qdisc replace dev eth1 root tbf rate 20mbit burst 32kbit latency 400ms
