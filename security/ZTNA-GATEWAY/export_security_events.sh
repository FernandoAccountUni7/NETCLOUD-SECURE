#!/bin/sh

DATE=$(date '+%Y-%m-%d %H:%M:%S')
COUNT=$(iptables -L FORWARD -n -v --line-numbers | grep 'ZTNA-DENY' | awk '{print $2}')

echo "$DATE | ZTNA-GATEWAY | ZTNA-DENY | blocked_packets=$COUNT"
