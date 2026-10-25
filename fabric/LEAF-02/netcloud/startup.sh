#!/bin/bash

/sbin/ip link show br10 >/dev/null 2>&1 || /sbin/ip link add br10 type bridge
/sbin/ip link set br10 up

/sbin/ip link set eth2 up
/sbin/ip link set eth2 master br10

/sbin/ip link show vxlan10010 >/dev/null 2>&1 || /sbin/ip link add vxlan10010 type vxlan id 10010 local 10.255.0.12 dstport 4789 nolearning
/sbin/ip link set vxlan10010 master br10
/sbin/ip link set vxlan10010 up

/sbin/ip addr show eth3 | grep -q "172.16.100.2/24" || /sbin/ip addr add 172.16.100.2/24 dev eth3
/sbin/ip link set eth3 up

id netauto >/dev/null 2>&1 || adduser -D netauto
echo 'netauto:CHANGE_ME_NETAUTO' | chpasswd
addgroup netauto frrvty 2>/dev/null || true

ssh-keygen -A >/dev/null 2>&1
pgrep sshd >/dev/null 2>&1 || /usr/sbin/sshd
