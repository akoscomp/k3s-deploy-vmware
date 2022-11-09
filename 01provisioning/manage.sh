#!/usr/bin/env bash
if [[ $# -gt 0 ]]; then
  NODES=$@
else
  echo "usage: $0 <nodename>"
  echo "usage: $0 k8s-test"
  exit 1
fi
#NODES="edu-test"

DATE=`date '+%Y%m%d-%H%M%S'`

while [[ $# -gt 0 ]] ;
do
    opt="$1";
    shift;              #expose next argument
    case "$opt" in
        "--" ) break 2;;
        "start" )
          echo "Start hosts: ${NODES}"
          for HOST in $NODES; do
            govc vm.power -dc=dc -on k8s-${HOST}
          done
        ;;
        "stop" )
          echo "Stop hosts: ${NODES}"
          for HOST in $NODES; do
            govc vm.power -dc=dc -off k8s-${HOST}
          done
        ;;
        "snap" )
          echo "Snaphost hosts: ${NODES}"
          for HOST in $NODES; do
            govc snapshot.create -dc=dc -vm k8s-${HOST} ${DATE}
          done
        ;;
        *)
          echo >&2 "Invalid option: $@";
          echo "Valid: start stop snap"
          exit 1
        ;;
   esac
done
