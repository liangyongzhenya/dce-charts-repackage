#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============


set -x

# the kernel of github ubuntu is too high , falco miss driver
exit 0


if ! helm get manifest -n kube-system falco --kubeconfig ${KIND_KUBECONFIG} &>/dev/null ; then
  ${CURRENT_DIR_PATH}/../falco/install.sh  "${CHART_DIR}/../../falco/falco" "${KIND_KUBECONFIG}"
  if (($?!=0)) ; then
    echo "failed to deploy falco"
    exit 1
  fi
fi

# deploy the spiderpool
helm install falco-exporter chart-museum/falco-exporter  ${HELM_MUST_OPTION} --namespace kube-system


if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A

  exit 1
fi
