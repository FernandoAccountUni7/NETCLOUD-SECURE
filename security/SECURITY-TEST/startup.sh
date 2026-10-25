#!/bin/sh

# IP SECURITY-TEST
/sbin/ip addr show eth0 | grep -q "172.16.100.60/24" || /sbin/ip addr add 172.16.100.60/24 dev eth0
/sbin/ip link set eth0 up

# Ruta hacia zona Zero Trust
/sbin/ip route show | grep -q "10.80.0.0/24 via 172.16.100.40" || /sbin/ip route add 10.80.0.0/24 via 172.16.100.40

echo "SECURITY-TEST-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Ruta hacia red N6
ip route show | grep -q "10.60.0.0/24 via 172.16.100.20" || \
ip route add 10.60.0.0/24 via 172.16.100.20
