#!/bin/sh

# Interfaz hacia 5G-CORE
/sbin/ip addr show eth0 | grep -q "10.61.0.2/30" || /sbin/ip addr add 10.61.0.2/30 dev eth0
/sbin/ip link set eth0 up

# Interfaz hacia N6
/sbin/ip addr show eth1 | grep -q "10.60.0.1/24" || /sbin/ip addr add 10.60.0.1/24 dev eth1
/sbin/ip link set eth1 up

# Routing
echo 1 > /proc/sys/net/ipv4/ip_forward

/sbin/ip route show | grep -q "10.45.0.0/16 via 10.61.0.1" || /sbin/ip route add 10.45.0.0/16 via 10.61.0.1

echo "VNF-FIREWALL-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Politica NFV: bloquear ICMP de UE hacia DATA-SERVER
iptables -C FORWARD -s 10.45.0.0/16 -d 10.60.0.2 -p icmp -j DROP 2>/dev/null || \
iptables -I FORWARD 1 -s 10.45.0.0/16 -d 10.60.0.2 -p icmp -j DROP

# Heartbeat NFV para failover
ip addr show eth0 | grep -q "192.168.250.1/24" || \
ip addr add 192.168.250.1/24 dev eth0

# Ruta de retorno hacia red de gestion
ip route show | grep -q "172.16.100.0/24 via 10.61.0.1" || \
ip route add 172.16.100.0/24 via 10.61.0.1

# Proteccion automatica contra HTTP Flood
iptables -N DDoS_GUARD 2>/dev/null || true
iptables -N DDOS_BLOCK 2>/dev/null || true
iptables -F DDoS_GUARD
iptables -F DDOS_BLOCK

iptables -A DDOS_BLOCK -m recent --name DDOS_BLACKLIST --set
iptables -A DDOS_BLOCK -j DROP

iptables -A DDoS_GUARD -m recent --name DDOS_BLACKLIST --rcheck --seconds 60 -j DROP
iptables -A DDoS_GUARD -m recent --name HTTP_FLOOD --set
iptables -A DDoS_GUARD -m recent --name HTTP_FLOOD --update --seconds 10 --hitcount 20 -j DDOS_BLOCK
iptables -A DDoS_GUARD -j ACCEPT

iptables -C FORWARD -s 172.16.100.60 -d 10.60.0.10 -p tcp --dport 80 -m conntrack --ctstate NEW -j DDoS_GUARD 2>/dev/null || \
iptables -I FORWARD 1 -s 172.16.100.60 -d 10.60.0.10 -p tcp --dport 80 -m conntrack --ctstate NEW -j DDoS_GUARD
