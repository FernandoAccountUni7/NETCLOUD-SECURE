#!/bin/sh

ip addr show eth1 | grep -q "172.16.100.10/24" || ip addr add 172.16.100.10/24 dev eth1
ip link set eth1 up

echo "AUTOMATION-NETCLOUD-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Ruta hacia la zona protegida Zero Trust
ip route show | grep -q "10.80.0.0/24 via 172.16.100.40" || ip route add 10.80.0.0/24 via 172.16.100.40
