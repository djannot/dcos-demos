export KUBECONFIG1=../../core/config.poc-prod-k8s-cluster1

cd $(dirname $0)

export PATH=$PWD/bin:$PATH
kubectl --kubeconfig=${KUBECONFIG1} create namespace istio-system
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl --kubeconfig=${KUBECONFIG1} apply -f -
sleep 30
until kubectl --kubeconfig=${KUBECONFIG1} get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l | grep 23
do
  sleep 1
done
kubectl --kubeconfig=${KUBECONFIG1} apply -f template.yaml
