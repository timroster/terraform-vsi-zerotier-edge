#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "-- net tools install --"
dnf install -y net-tools iptables-services iptables-utils

if [ "${install_squid}" = "true" ]; then
  echo "-- squid install --"
  dnf install -y squid
  systemctl enable squid
  systemctl start squid
fi

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

echo "-- ZeroTier identity --"
mkdir -p /var/lib/zerotier-one/
echo ${zt_identity.public_key} > /var/lib/zerotier-one/identity.public
chmod 0644 /var/lib/zerotier-one/identity.public
echo ${zt_identity.private_key} > /var/lib/zerotier-one/identity.secret
chmod 0600 /var/lib/zerotier-one/identity.secret

echo "-- ZeroTier --"
### temp workaround for: https://github.com/zerotier/ZeroTierOne/issues/1575
dnf install -y compat-openssl10
curl -s https://install.zerotier.com | bash

# give ZeroTier service a moment to start...
sleep 30

zerotier-cli join ${zt_network}
while ! zerotier-cli listnetworks | grep ${zt_network} | grep OK ;
do
  sleep 1
done

echo "-- script finished! --"