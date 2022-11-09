# 01 Provistion the cluster VM's
## Configure the deployment:
* Modify only `.yaml` files, create file for each nodename
* run `build-onenode.sh <nodename>`
* Login to node, `cat /etc/rancher/k3s/k3s.yaml`

## Configure for storage:
To access the storage, need to add and configure the v0603-storage-dev vlan
govc vm.network.add \
  -dc=dc \
  -net "v0603" \
  -net.adapter=E1000 \
  -vm ${VM_NAME}

# Related docs:
### Govc documentation:
https://github.com/vmware/govmomi/blob/master/govc/USAGE.md

### Download flatcar linux from:
https://lts.release.flatcar-linux.net/amd64-usr/current/
https://lts.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ovf
https://lts.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova_image.vmdk.bz2 (unzip)

### (Optional) Extract configuration parameters:
`govc import.spec ~/Downloads/iso/flatcar_production_vmware_ova.ova | python3 -m json.tool > govc-flatcar-spec.json`

### Install ova:
`govc import.ova -name=k8s-edu-node1 -dc=dc -ds=nfs6-k8s -folder=k8s -options=govc-flatcar-spec.json ~/Downloads/iso/flatcar_production_vmware_ova.ova`

### ignition.json
* https://forum.tinyserve.com/d/14-how-to-install-flatcar-in-vmware-esxi-just-on-webui
* https://www.base64encode.org/enc/ignition/
* Convert to base64: `cat ignison.json | base64`
* Copy output to govc-flatcar-spec.json

* Encode yaml to base64, insert it on vmware settings advanced propertyes
`cat cl1.yaml | docker run --rm -i ghcr.io/flatcar/ct:latest -platform custom | base64 --wrap=0`

