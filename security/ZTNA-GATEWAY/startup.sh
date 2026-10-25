#!/bin/sh

# Lado de acceso / gestion
/sbin/ip addr show eth0 | grep -q "172.16.100.40/24" || /sbin/ip addr add 172.16.100.40/24 dev eth0
/sbin/ip link set eth0 up

# Zona protegida Zero Trust
/sbin/ip addr show eth1 | grep -q "10.80.0.1/24" || /sbin/ip addr add 10.80.0.1/24 dev eth1
/sbin/ip link set eth1 up

# Routing
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "ZTNA-GATEWAY-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Zero Trust: deny-by-default
iptables -F FORWARD
iptables -P FORWARD DROP

# Permitir trafico de retorno
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Unicamente AUTOMATION puede acceder al recurso HTTP protegido
iptables -A FORWARD -s 172.16.100.10 -d 10.80.0.10 -p tcp --dport 80 -j ACCEPT

# Registrar intentos no autorizados hacia el recurso Zero Trust
iptables -A FORWARD -d 10.80.0.10 -j LOG --log-prefix "ZTNA-DENY " --log-level 4

# SSH para recoleccion SIEM
id monitor >/dev/null 2>&1 || adduser -D monitor
echo 'monitor:CHANGE_ME_MONITOR' | chpasswd
ssh-keygen -A >/dev/null 2>&1
pgrep -x sshd >/dev/null 2>&1 || /usr/sbin/sshd

# Recolector de eventos Zero Trust
pgrep -f "/opt/netcloud/security_collector.sh" >/dev/null 2>&1 || \
nohup /opt/netcloud/security_collector.sh > /opt/netcloud/security_collector.log 2>&1 &
