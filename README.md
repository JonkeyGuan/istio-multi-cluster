# istio-multi-cluster

```
kubectl config set-context ctx-hub \
--namespace=kube-system \
--cluster=api-hub-jonkey-cc:6443 \
--user=hub-admin 

kubectl config set-credentials hub-admin --token=sha256~xyz

kubectl config set-context ctx-ocp11 \
--namespace=kube-system \
--cluster=api-ocp11-jonkey-cc:6443 \
--user=ocp11-admin 

kubectl config set-credentials ocp11-admin --token=sha256~abc


kubectl --context=ctx-hub create ns test
kubectl --context=ctx-hub label namespace test istio-injection=enabled --overwrite

kubectl --context=ctx-ocp11 create ns test
kubectl --context=ctx-ocp11 label namespace test istio-injection=enabled --overwrite

```

