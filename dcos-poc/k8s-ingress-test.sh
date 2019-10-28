kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-1,owner=dklb --port 80 http-echo-1 -- -listen=:80 --text='Hello from http-echo-1!'
kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-2,owner=dklb --port 80 http-echo-2 -- -listen=:80 --text='Hello from http-echo-2!'

kubectl expose pod http-echo-1 --port 80 --target-port 80 --type NodePort --name "http-echo-1"
kubectl expose pod http-echo-2 --port 80 --target-port 80 --type NodePort --name "http-echo-2"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout http-echo-1-tls.key -out http-echo-1-tls.crt -subj "/CN=http-echo-1.com"
kubectl create secret tls http-echo-1 --key http-echo-1-tls.key --cert http-echo-1-tls.crt

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout http-echo-2-tls.key -out http-echo-2-tls.crt -subj "/CN=http-echo-2.com"
kubectl create secret tls http-echo-2 --key http-echo-2-tls.key --cert http-echo-2-tls.crt

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: edgelb
    kubernetes.dcos.io/dklb-config: |
      name: dklb
      size: ${PUBLICNODES}
      frontends:
        http:
          mode: enabled
          port: ${K8SINGRESSPORT}
        https:
          port: ${K8SINGRESSTLSPORT}
  labels:
    owner: dklb
  name: dklb-echo
spec:
  tls:
  - hosts:
    - http-echo-1.com
    secretName: http-echo-1
  - hosts:
    - http-echo-2.com
    secretName: http-echo-2
  rules:
  - host: http-echo-1.com
    http:
      paths:
      - backend:
          serviceName: http-echo-1
          servicePort: 80
  - host: http-echo-2.com
    http:
      paths:
      - backend:
          serviceName: http-echo-2
          servicePort: 80
EOF

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: edgelb
    kubernetes.dcos.io/dklb-config: |
      name: dklb
  labels:
    owner: dklb
  name: dklb-echo-2
spec:
  rules:
  - host: http-echo-3.com
    http:
      paths:
      - backend:
          serviceName: http-echo-1
          servicePort: 80
EOF

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: edgelb
    kubernetes.dcos.io/dklb-config: |
      name: dklb
  labels:
    owner: dklb
  name: dklb-echo-3
spec:
  rules:
  - host: http-echo-4.com
    http:
      paths:
      - backend:
          serviceName: http-echo-1
          servicePort: 80
EOF
