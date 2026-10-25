#!/bin/sh

ip addr del 10.61.0.2/30 dev eth0 2>/dev/null
ip addr del 10.60.0.1/24 dev eth1 2>/dev/null
ip route del 10.45.0.0/16 via 10.61.0.1 2>/dev/null

echo "$(date '+%Y-%m-%d %H:%M:%S') | BACKUP-PASSIVE" >> /opt/netcloud/failover.log
