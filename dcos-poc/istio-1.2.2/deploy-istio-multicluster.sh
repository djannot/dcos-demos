export KUBECONFIG1=../../core/config.poc-prod-k8s-cluster1
export KUBECONFIG2=../../core/config.poc-prod-k8s-cluster2

cd $(dirname $0)

export PATH=$PWD/bin:$PATH
kubectl --kubeconfig=${KUBECONFIG1} create namespace istio-system
kubectl --kubeconfig=${KUBECONFIG1} create secret generic cacerts -n istio-system \
    --from-file=samples/certs/ca-cert.pem \
    --from-file=samples/certs/ca-key.pem \
    --from-file=samples/certs/root-cert.pem \
    --from-file=samples/certs/cert-chain.pem
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl --kubeconfig=${KUBECONFIG1} apply -f -
until kubectl --kubeconfig=${KUBECONFIG1} get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l | grep 23
do
  sleep 1
done
kubectl --kubeconfig=${KUBECONFIG1} apply -f template-multicluster1.yaml
kubectl --kubeconfig=${KUBECONFIG2} create namespace istio-system
kubectl --kubeconfig=${KUBECONFIG2} create secret generic cacerts -n istio-system \
    --from-file=samples/certs/ca-cert.pem \
    --from-file=samples/certs/ca-key.pem \
    --from-file=samples/certs/root-cert.pem \
    --from-file=samples/certs/cert-chain.pem
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl --kubeconfig=${KUBECONFIG2} apply -f -
until kubectl --kubeconfig=${KUBECONFIG2} get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l | grep 23
do
  sleep 1
done
kubectl --kubeconfig=${KUBECONFIG2} apply -f template-multicluster2.yaml

kubectl --kubeconfig=${KUBECONFIG1} apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"Corefile":".:10053 {\n    errors\n    health :8081\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n      pods insecure\n      upstream\n      fallthrough in-addr.arpa ip6.arpa\n    }\n    prometheus :9153\n    proxy . /etc/resolv.conf\n    cache 30\n    reload\n    loadbalance\n}\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"coredns","namespace":"kube-system"}}
data:
  Corefile: |
    .:10053 {
        errors
        health :8081
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        reload
        loadbalance
    }
    global:10053 {
        errors
        cache 30
        proxy . $(kubectl --kubeconfig=${KUBECONFIG1} get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})
    }
EOF

kubectl --kubeconfig=${KUBECONFIG2} apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"Corefile":".:10053 {\n    errors\n    health :8081\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n      pods insecure\n      upstream\n      fallthrough in-addr.arpa ip6.arpa\n    }\n    prometheus :9153\n    proxy . /etc/resolv.conf\n    cache 30\n    reload\n    loadbalance\n}\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"coredns","namespace":"kube-system"}}
data:
  Corefile: |
    .:10053 {
        errors
        health :8081
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        proxy . /etc/resolv.conf
        cache 30
        reload
        loadbalance
    }
    global:10053 {
        errors
        cache 30
        proxy . $(kubectl --kubeconfig=${KUBECONFIG2} get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})
    }
EOF
