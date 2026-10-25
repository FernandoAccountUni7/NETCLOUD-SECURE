#!/bin/bash

# ==============================
# NETCLOUD 5G CORE - STARTUP
# ==============================

# Interfaces físicas
/bin/ip addr show eth0 | grep -q "10.50.0.1/24" || /bin/ip addr add 10.50.0.1/24 dev eth0
/bin/ip link set eth0 up

/bin/ip addr show eth1 | grep -q "172.16.100.20/24" || /bin/ip addr add 172.16.100.20/24 dev eth1
/bin/ip link set eth1 up

/bin/ip addr show eth2 | grep -q "10.61.0.1/30" || /bin/ip addr add 10.61.0.1/30 dev eth2
/bin/ip link set eth2 up

# Interfaz TUN para las UE
/bin/ip link show ogstun >/dev/null 2>&1 || /bin/ip tuntap add name ogstun mode tun
/bin/ip addr show ogstun | grep -q "10.45.0.1/16" || /bin/ip addr add 10.45.0.1/16 dev ogstun
/bin/ip link set ogstun up

# MongoDB
pgrep mongod >/dev/null 2>&1 || mongod --dbpath /var/lib/mongodb --logpath /opt/netcloud/mongodb.log --fork
sleep 3

# NRF
pgrep -x open5gs-nrfd >/dev/null 2>&1 || nohup open5gs-nrfd -c /etc/open5gs/nrf.yaml > /opt/netcloud/nrf.log 2>&1 &
sleep 3

# SCP
pgrep -x open5gs-scpd >/dev/null 2>&1 || nohup open5gs-scpd -c /etc/open5gs/scp.yaml > /opt/netcloud/scp.log 2>&1 &
sleep 2

# Subscriber / Authentication functions
pgrep -x open5gs-udrd >/dev/null 2>&1 || nohup open5gs-udrd -c /etc/open5gs/udr.yaml > /opt/netcloud/udr.log 2>&1 &
pgrep -x open5gs-udmd >/dev/null 2>&1 || nohup open5gs-udmd -c /etc/open5gs/udm.yaml > /opt/netcloud/udm.log 2>&1 &
pgrep -x open5gs-ausfd >/dev/null 2>&1 || nohup open5gs-ausfd -c /etc/open5gs/ausf.yaml > /opt/netcloud/ausf.log 2>&1 &
sleep 2

# Control plane
pgrep -x open5gs-pcfd >/dev/null 2>&1 || nohup open5gs-pcfd -c /etc/open5gs/pcf.yaml > /opt/netcloud/pcf.log 2>&1 &
pgrep -x open5gs-nssfd >/dev/null 2>&1 || nohup open5gs-nssfd -c /etc/open5gs/nssf.yaml > /opt/netcloud/nssf.log 2>&1 &
pgrep -x open5gs-bsfd >/dev/null 2>&1 || nohup open5gs-bsfd -c /etc/open5gs/bsf.yaml > /opt/netcloud/bsf.log 2>&1 &
sleep 2

# Session / User plane
pgrep -x open5gs-smfd >/dev/null 2>&1 || nohup open5gs-smfd -c /etc/open5gs/smf.yaml > /opt/netcloud/smf.log 2>&1 &
pgrep -x open5gs-upfd >/dev/null 2>&1 || nohup open5gs-upfd -c /etc/open5gs/upf.yaml > /opt/netcloud/upf.log 2>&1 &
sleep 2

# AMF al final para recibir gNodeB cuando el resto del Core ya está disponible
pgrep -x open5gs-amfd >/dev/null 2>&1 || nohup open5gs-amfd -c /etc/open5gs/amf.yaml > /opt/netcloud/amf.log 2>&1 &

echo "NETCLOUD-5G-CORE-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# IPv4 forwarding para tráfico UE hacia N6
echo 1 > /proc/sys/net/ipv4/ip_forward

# Ruta hacia la red N6 a través del VNF Firewall
/bin/ip route show | grep -q "10.60.0.0/24 via 10.61.0.2" || /bin/ip route add 10.60.0.0/24 via 10.61.0.2
