#!/bin/bash

# IP de gestion
ip addr show eth0 | grep -q "172.16.100.80/24" || \
ip addr add 172.16.100.80/24 dev eth0

ip link set eth0 up

# Rutas hacia segmentos internos NETCLOUD
ip route replace 10.80.0.0/24 via 172.16.100.40
ip route replace 10.60.0.0/24 via 172.16.100.20
ip route replace 10.61.0.0/30 via 172.16.100.20

# Exporter
pgrep -f "/opt/netcloud/metrics_exporter.py" >/dev/null 2>&1 || \
nohup python /opt/netcloud/metrics_exporter.py \
> /opt/netcloud/exporter.log 2>&1 &

sleep 2

# Prometheus
pgrep -x prometheus >/dev/null 2>&1 || \
nohup prometheus \
--config.file=/opt/netcloud/prometheus.yml \
--storage.tsdb.path=/opt/netcloud/prometheus-data \
--web.listen-address=0.0.0.0:9090 \
> /opt/netcloud/prometheus.log 2>&1 &

sleep 3

# Dashboard
pgrep -f "/opt/netcloud/dashboard.py" >/dev/null 2>&1 || \
nohup python /opt/netcloud/dashboard.py \
> /opt/netcloud/dashboard.log 2>&1 &

echo "PROMETHEUS-DASHBOARD-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
