#!/usr/bin/env bash
if [[ $# -gt 0 ]]; then
  NODES=$@
else
  echo "usage: $0 <nodename>"
  echo "usage: $0 k8s-test"
  exit 1
fi
#NODES="edu-test"

for NODE in $NODES; do
  echo "Start to deploy VM ${NODE}:"
  BASE64=`cat ${NODE}.yaml | docker run --rm -i ghcr.io/flatcar/ct:latest -platform custom | base64 --wrap=0`
  #BASE64=$(base64 -w0 ${NODE}.yaml)
  sed "s/REPLACEBASE64/${BASE64}/g" ignition.json.template > ${NODE}.json
  govc import.ova -name=${NODE} -dc=dc -ds=nfs6-k8s -folder=k8s -options=${NODE}.json ./flatcar_production_vmware_ova.ova

  if [ $? -eq 0 ]; then
    sleep 1
    echo "Configure vm, disk and env"
    govc vm.change -dc=dc -vm ${NODE} -c=8 -m=32768
    govc vm.network.change -dc=dc -vm ${NODE} -net=v0109 ethernet-0
    govc vm.disk.change -dc=dc -vm ${NODE} -disk.label "Hard disk 1" -size 100G
    govc vm.change -dc=dc -vm ${NODE} -e 'guestinfo.cloud-init.config.data'=$(base64 -w0 ${NODE}.yaml)
    govc vm.change -dc=dc -vm ${NODE} -e 'guestinfo.cloud-init.data.encoding'='base64'
    # Add secondary network adapter for storage access
    govc vm.network.add -dc=dc -net "v0603" -net.adapter=vmxnet3 -vm ${NODE}
    echo "All config are applied, power on!"
    sleep 1
    govc vm.power -dc=dc -on ${NODE}
    echo "Connect to new node and get kubeconfig file: cat /etc/rancher/k3s/k3s.yaml"
  else
      echo FAIL
      exit 1
  fi
done
