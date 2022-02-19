#!/usr/bin/env bash

echo "-- ZeroTier identity --"
mkdir -p /var/lib/zerotier-one/
cp .zt_identity-public_key > /var/lib/zerotier-one/identity.public
chmod 0644 /var/lib/zerotier-one/identity.public
cp .zt_identity-private_key > /var/lib/zerotier-one/identity.secret
chmod 0600 /var/lib/zerotier-one/identity.secret

echo "-- ZeroTier --"
curl -s https://install.zerotier.com | bash

# give ZeroTier service a moment to start...
sleep 30

zerotier-cli join ${zt_network}
while ! zerotier-cli listnetworks | grep ${zt_network} | grep OK ;
do
  sleep 1
done

INSTANCE_IP=$(cat .instance-ip)

echo "Private key"
cat .private-key

echo "Connecting to ssh server: ${INSTANCE_IP}"

ssh -o "StrictHostKeyChecking no" -i .private-key root@$(cat .INSTANCE-ip) ls
