#!/bin/bash

# IP persistente del servidor gRPC
ip addr show eth0 | grep -q "172.16.100.70/24" || \
ip addr add 172.16.100.70/24 dev eth0

ip link set eth0 up

# Servidor gRPC
pgrep -f "/opt/netcloud/grpc_server.py" >/dev/null 2>&1 || \
nohup python /opt/netcloud/grpc_server.py \
> /opt/netcloud/grpc_server.log 2>&1 &

echo "TELEMETRY-GRPC-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
