#!/bin/sh

# Tomar IP de servicio del firewall principal
ip addr show eth0 | grep -q "10.61.0.2/30" || \
ip addr add 10.61.0.2/30 dev eth0

ip addr show eth1 | grep -q "10.60.0.1/24" || \
ip addr add 10.60.0.1/24 dev eth1

# Ruta hacia las sesiones UE a traves del 5G Core
ip route show | grep -q "10.45.0.0/16 via 10.61.0.1" || \
ip route add 10.45.0.0/16 via 10.61.0.1

# Forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null

# Politica equivalente al firewall principal
iptables -F FORWARD
iptables -P FORWARD ACCEPT

iptables -A FORWARD \
-s 10.45.0.0/16 \
-d 10.60.0.2 \
-p icmp \
-j DROP

# Gratuitous ARP para actualizar vecinos inmediatamente
arping -U -c 3 -I eth0 -s 10.61.0.2 10.61.0.2 >/dev/null 2>&1
arping -U -c 3 -I eth1 -s 10.60.0.1 10.60.0.1 >/dev/null 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') | BACKUP-ACTIVE" >> /opt/netcloud/failover.log
