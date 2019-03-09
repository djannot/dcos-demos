cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export URL=$(echo ${SERVICEPATH} | sed 's/\//\./g')

if [ -f ~/.kube/config ]; then
  mv ~/.kube/config ~/.kube/config.ori
fi

dcos kubernetes cluster kubeconfig --context-name=${SERVICEACCOUNT} --cluster-name=${SERVICEPATH} \
  --apiserver-url https://${URL}.mesos.lab:8443 \
  --insecure-skip-tls-verify
mv ~/.kube/config ./config.${SERVICEACCOUNT}

if [ -f ~/.kube/config.ori ]; then
  mv ~/.kube/config.ori ~/.kube/config
fi
