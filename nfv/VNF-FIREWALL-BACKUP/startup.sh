#!/bin/sh

# Interfaces propias del firewall backup
ip addr show eth0 | grep -q "192.168.250.2/24" || \
ip addr add 192.168.250.2/24 dev eth0

ip addr show eth1 | grep -q "10.60.0.254/24" || \
ip addr add 10.60.0.254/24 dev eth1

ip link set eth0 up
ip link set eth1 up

# Forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null


echo "VNF-FIREWALL-BACKUP-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Monitor automatico de failover NFV
pgrep -f "/opt/netcloud/failover_monitor.sh" >/dev/null 2>&1 || \
nohup /opt/netcloud/failover_monitor.sh > /opt/netcloud/failover_monitor.log 2>&1 &

# Ruta hacia red de gestion mientras el nodo esta pasivo
ip route show | grep -q "172.16.100.0/24 via 192.168.250.1" || \
ip route add 172.16.100.0/24 via 192.168.250.1
