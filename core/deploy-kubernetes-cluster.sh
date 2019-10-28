cd $(dirname $0)

export K8SHA=false
if $2; then
  export K8SHA=true
fi

export K8SVERSION=2.4.5-1.15.5
if [ ! -z "$3" ]; then
  export K8SVERSION=$3
fi

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:user:root create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:agent:task:user:root create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:slave_public/${ROLE} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:slave_public/${ROLE} read
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation:role:slave_public/${ROLE} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:volume:role:slave_public/${ROLE} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:slave_public read
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:agent:framework:role:slave_public read

./rendertemplate.sh options-kubernetes-cluster.json.template > options-kubernetes-cluster.json
dcos kubernetes cluster create --yes --options=options-kubernetes-cluster.json --package-version=${K8SVERSION}
