#!/bin/bash

set -xe

export clusters=$@

cert_dir=`dirname "$BASH_SOURCE"`/certs

mkdir -p tmp

for cluster in ${clusters}; do
    export cluster
    envsubst < namespace.yaml > tmp/namespace-${cluster}.yaml
    kubectl --context="ctx-${cluster}" apply -f tmp/namespace-${cluster}.yaml
done

for cluster in ${clusters}; do
    export cluster
    kubectl create secret generic cacerts -n istio-system \
        --from-file=${cert_dir}/${cluster}/ca-cert.pem \
        --from-file=${cert_dir}/${cluster}/ca-key.pem \
        --from-file=${cert_dir}/root-cert.pem \
        --from-file=${cert_dir}/${cluster}/cert-chain.pem --dry-run=client -o yaml > tmp/certs.yaml
    kubectl --context="ctx-${cluster}" -n istio-system apply -f tmp/certs.yaml
done

for cluster in ${clusters}; do
    export cluster
    envsubst < controlplane.yaml > tmp/controlplane-${cluster}.yaml
    istioctl --context="ctx-${cluster}" install -y -f tmp/controlplane-${cluster}.yaml
done

for cluster in ${clusters}; do
    export cluster
    envsubst < eastwest-gateway.yaml > tmp/eastwest-gateway-${cluster}.yaml
    istioctl --context="ctx-${cluster}" install -y -f tmp/eastwest-gateway-${cluster}.yaml
done

for cluster in ${clusters}; do
    export cluster
    kubectl --context="ctx-${cluster}" apply -n istio-system -f ./expose-services.yaml
done

for cluster1 in ${clusters}; do
    export cluster1
    for cluster2 in ${clusters}; do
        export cluster1
        if [ ${cluster2} != ${cluster1} ]; then
            istioctl --context="ctx-${cluster2}" create-remote-secret --name="cluster-${cluster2}" > tmp/cluster-secret-${cluster2}.yaml
            kubectl --context="ctx-${cluster1}" apply -f tmp/cluster-secret-${cluster2}.yaml
        fi
    done
done
