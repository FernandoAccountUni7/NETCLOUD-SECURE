#!/bin/sh

while true
do
    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    EVENT=$(ssh -o StrictHostKeyChecking=no monitor@172.16.100.40 \
    "cat /opt/netcloud/security_status.log" 2>/dev/null)

    if [ -n "$EVENT" ]; then
        echo "$DATE | $EVENT" >> /opt/netcloud/siem_events.log
    else
        echo "$DATE | ZTNA-GATEWAY | COLLECTION-ERROR" >> /opt/netcloud/siem_events.log
    fi

    sleep 60
done
