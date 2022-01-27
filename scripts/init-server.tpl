#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "-- squid and net tools install --"
dnf install -y squid net-tools iptables-services iptables-utils
systemctl enable squid
systemctl start squid

echo "-- iptables --"
iptables -I INPUT -p udp --dport 9993 -j ACCEPT
iptables -I INPUT -p udp --dport 53 -j ACCEPT
iptables -I INPUT -p tcp --dport 53 -j ACCEPT
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
iptables -t nat -A POSTROUTING --dst 166.8.0.0/14 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
systemctl enable iptables

echo "-- ip forwarding --"
echo "# allow IP forwarding" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.forwarding=1

echo "-- ZeroTier --"
curl -s https://install.zerotier.com | bash

zerotier-cli join ${zt_network}
while ! zerotier-cli listnetworks | grep ${zt_network} | grep OK ;
do
  sleep 1
done

echo "-- script finished! --"