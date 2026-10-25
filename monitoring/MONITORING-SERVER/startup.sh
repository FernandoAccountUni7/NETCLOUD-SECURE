#!/bin/sh

/sbin/ip addr show eth0 | grep -q "172.16.100.50/24" || /sbin/ip addr add 172.16.100.50/24 dev eth0
/sbin/ip link set eth0 up

echo "MONITORING-SERVER-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt

# Monitoreo automatico cada 60 segundos
pgrep -f "/opt/netcloud/monitor_loop.sh" >/dev/null 2>&1 || \
nohup /opt/netcloud/monitor_loop.sh > /opt/netcloud/monitor_loop.log 2>&1 &

# Recolector SIEM de eventos Zero Trust
pgrep -f "/opt/netcloud/siem_collector.sh" >/dev/null 2>&1 || \
nohup /opt/netcloud/siem_collector.sh > /opt/netcloud/siem_collector.log 2>&1 &
