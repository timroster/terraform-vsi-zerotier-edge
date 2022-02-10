#!/bin/sh
CLUSTER=$1

# apply proxy configuration to cluster
oc apply -f proxy-config.yaml

# create daemonset to update crio on workers -TODO- check running status and remove sleep
oc create -f setcrioproxy.yaml
echo "Waiting for daemonset to update workers..."
sleep 180

# do a rolling reboot of all workers
echo "Performing rolling reboot of workers, 10 min wait after each reboot"
for WORKER in $(ibmcloud cs worker ls --cluster ${CLUSTER} | grep kube | cut -d' ' -f1); do
    echo "rebooting $WORKER..."
    ibmcloud cs worker reboot -f --skip-master-health --worker $WORKER --cluster ${CLUSTER};
    sleep 300;
done