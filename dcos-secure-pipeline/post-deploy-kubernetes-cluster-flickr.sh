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

if ${SECURE}; then
  kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create secret generic dcos-ca --from-file=../core/dcos-ca.crt
  kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create secret generic krb5-conf --from-file=../core/krb5.conf
  kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create secret generic merged-keytab --from-file=../core/merged.keytab
fi
