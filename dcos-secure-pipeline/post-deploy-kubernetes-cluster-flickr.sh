export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
EOF

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secret
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create rolebinding jenkins \
  --clusterrole=cluster-admin \
  --serviceaccount=default:jenkins \
  --namespace=default

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} describe secrets/jenkins-secret

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f dklb-prereqs.yaml
kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f dklb-deployment.yaml
