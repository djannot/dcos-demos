cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

./create-service-account.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:default:/${SERVICEPATH}/* full
dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:list:default:/${SERVICEPATH} full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:marathon full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:package full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:edgelb full
dcos security org users grant ${SERVICEACCOUNT} dcos:service:marathon:marathon:services:/${SERVICEPATH} full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:endpoint:path:/api/v1 full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:endpoint:path:/api/v1/scheduler full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:principal:${SERVICEACCOUNT} full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation:principal:${SERVICEACCOUNT} full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:volume:principal:${SERVICEACCOUNT} full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:volume:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:user:root full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:app_id full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:${SERVICEPATH}/pools/all full

dcos package repo add --index=0 edgelb-aws https://downloads.mesosphere.com/edgelb/v1.3.0/assets/stub-universe-edgelb.json
dcos package repo add --index=0 edgelb-pool-aws https://downloads.mesosphere.com/edgelb-pool/v1.3.0/assets/stub-universe-edgelb-pool.json

./rendertemplate.sh options-edgelb.json.template > options-edgelb.json
dcos package install --yes edgelb --options=options-edgelb.json --package-version=v1.3.0
