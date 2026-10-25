#!/bin/bash

# ==============================
# NETCLOUD UERANSIM - STARTUP
# ==============================

# Interfaces
/bin/ip addr show eth0 | grep -q "10.50.0.2/24" || /bin/ip addr add 10.50.0.2/24 dev eth0
/bin/ip link set eth0 up

/bin/ip addr show eth1 | grep -q "172.16.100.30/24" || /bin/ip addr add 172.16.100.30/24 dev eth1
/bin/ip link set eth1 up

sleep 5

# gNodeB
pgrep -x nr-gnb >/dev/null 2>&1 || nohup /opt/UERANSIM/build/nr-gnb -c /opt/UERANSIM/config/open5gs-gnb.yaml > /opt/netcloud/gnb.log 2>&1 &

sleep 8

# UE
pgrep -x nr-ue >/dev/null 2>&1 || nohup /opt/UERANSIM/build/nr-ue -c /opt/UERANSIM/config/open5gs-ue.yaml > /opt/netcloud/ue.log 2>&1 &

echo "NETCLOUD-UERANSIM-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Esperar a que UERANSIM cree la interfaz de la UE
for i in $(seq 1 30); do
    /bin/ip link show uesimtun0 >/dev/null 2>&1 && break
    sleep 1
done

# Ruta hacia la red N6 por la sesion PDU
/bin/ip route show | grep -q "10.60.0.0/24 dev uesimtun0" || /bin/ip route add 10.60.0.0/24 dev uesimtun0
