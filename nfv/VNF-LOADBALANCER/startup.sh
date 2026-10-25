#!/bin/sh

# Interfaz hacia N6
/sbin/ip addr show eth0 | grep -q "10.60.0.10/24" || /sbin/ip addr add 10.60.0.10/24 dev eth0
/sbin/ip link set eth0 up

# Interfaz hacia backends
/sbin/ip addr show eth1 | grep -q "10.62.0.1/24" || /sbin/ip addr add 10.62.0.1/24 dev eth1
/sbin/ip link set eth1 up

# Ruta de retorno hacia la red UE
/sbin/ip route show | grep -q "10.45.0.0/16 via 10.60.0.1" || /sbin/ip route add 10.45.0.0/16 via 10.60.0.1

echo "VNF-LOADBALANCER-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# HAProxy Load Balancer
pgrep -x haproxy >/dev/null 2>&1 || haproxy -f /etc/haproxy/haproxy.cfg

# Ruta de retorno hacia red de gestion
ip route show | grep -q "172.16.100.0/24 via 10.60.0.1" || \
ip route add 172.16.100.0/24 via 10.60.0.1
