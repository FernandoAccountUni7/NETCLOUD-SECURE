#!/bin/bash

# IP persistente del collector
ip addr show eth0 | grep -q "172.16.100.71/24" || \
ip addr add 172.16.100.71/24 dev eth0

ip link set eth0 up

# Cliente recolector gRPC
pgrep -f "/opt/netcloud/grpc_client.py" >/dev/null 2>&1 || \
nohup python /opt/netcloud/grpc_client.py \
> /opt/netcloud/grpc_client.log 2>&1 &

echo "TELEMETRY-COLLECTOR-READY" > /opt/netcloud/startup_status.txt
date >> /opt/netcloud/startup_status.txt
