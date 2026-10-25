#!/bin/sh

while true
do
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    COUNT=$(iptables -L FORWARD -n -v --line-numbers | grep 'ZTNA-DENY' | awk '{print $2}')

    echo "$DATE | ZTNA-GATEWAY | ZTNA-DENY | blocked_packets=$COUNT" > /opt/netcloud/security_status.log
    chmod 644 /opt/netcloud/security_status.log

    sleep 60
done
