export KUBECONFIG1=../../core/config.poc-prod-k8s-cluster1

cd $(dirname $0)

export PATH=$PWD/bin:$PATH
kubectl --kubeconfig=${KUBECONFIG1} apply -f <(istioctl --kubeconfig=${KUBECONFIG1} kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)
kubectl --kubeconfig=${KUBECONFIG1} apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
