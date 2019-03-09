cd $(dirname $0)

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
dcos kubernetes cluster create --yes --options=options-kubernetes-cluster.json --package-version=2.2.0-1.13.3
