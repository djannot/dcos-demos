cat <<EOF | kubectl --kubeconfig=../core/config.${APPNAME}-prod-k8s-cluster1 create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: redis
  name: redis
spec:
  containers:
  - name: redis
    image: redis:5.0.3
    ports:
    - name: redis
      containerPort: 6379
      protocol: TCP
EOF

cat <<EOF | kubectl --kubeconfig=../core/config.${APPNAME}-prod-k8s-cluster1 create -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubernetes.dcos.io/dklb-config: |
      name: "dklb"
      size: ${PUBLICNODES}
      frontends:
      - port: ${K8SLBPORT}
        servicePort: 6379
  labels:
    app: redis
  name: redis
spec:
  type: LoadBalancer
  selector:
    app: redis
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
EOF
