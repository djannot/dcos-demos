cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:superuser full
dcos security org users grant dcos_marathon dcos:mesos:master:task:user:root create
dcos security org users create -p password portworx
dcos security org users grant portworx dcos:secrets:default:/${SERVICEPATH}/secrets/* full

./rendertemplate.sh options-portworx.json.template > options-portworx.json
dcos package install --yes portworx --options=options-portworx.json --package-version=1.3.5-2.0.3
