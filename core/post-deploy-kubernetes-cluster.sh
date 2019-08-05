cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export URL=$(echo ${SERVICEPATH} | sed 's/\//\./g')

if [[ -z "${KUBECONFIG}" ]]; then
  export KUBECONFIG=~/.kube/config
fi

if [ -f ${KUBECONFIG} ]; then
  mv ${KUBECONFIG} ${KUBECONFIG}.ori
fi

dcos kubernetes cluster kubeconfig --context-name=${SERVICEACCOUNT} --cluster-name=${SERVICEPATH} \
  --apiserver-url https://${URL}.mesos.lab:8443 \
  --insecure-skip-tls-verify
mv ${KUBECONFIG} ./config.${SERVICEACCOUNT}

if [ -f ${KUBECONFIG}.ori ]; then
  mv ${KUBECONFIG}.ori ${KUBECONFIG}
fi

./create-dklb-secret.sh ${SERVICEACCOUNT}

kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f dklb-prereqs.yaml
./rendertemplate.sh dklb-deployment.yaml.template > dklb-deployment.yaml
kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} create -f dklb-deployment.yaml
