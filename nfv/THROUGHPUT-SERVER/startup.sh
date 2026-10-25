#!/bin/sh

/sbin/ip addr show eth0 | grep -q "10.60.0.3/24" || /sbin/ip addr add 10.60.0.3/24 dev eth0
/sbin/ip link set eth0 up

/sbin/ip route show | grep -q "^default via 10.60.0.1" || /sbin/ip route add default via 10.60.0.1

pgrep -x iperf3 >/dev/null 2>&1 || nohup iperf3 -s > /opt/netcloud/iperf3.log 2>&1 &
