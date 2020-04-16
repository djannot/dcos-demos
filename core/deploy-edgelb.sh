cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

./create-service-account.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:ro full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:rw full
dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:default:/${SERVICEPATH}/pools/* full
dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:list:default:/${SERVICEPATH}/pools/* full
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
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:${SERVICEPATH}/pools/dklb full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:${SERVICEPATH}/pools/auto-default full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:service:${SERVICEPATH}/pools/auto-edgelb-template full

dcos package repo remove edgelb-aws
dcos package repo add --index=0 edgelb-aws https://universe-converter.mesosphere.com/transform?url=https://downloads.mesosphere.com/edgelb/v1.5.1/assets/stub-universe-edgelb.json

dcos package repo remove edgelb-pool-aws
dcos package repo add --index=0 edgelb-pool-aws https://universe-converter.mesosphere.com/transform?url=https://downloads.mesosphere.com/edgelb-pool/v1.5.1/assets/stub-universe-edgelb-pool.json

./rendertemplate.sh options-edgelb.json.template > options-edgelb.json
dcos package install --yes edgelb --options=options-edgelb.json --package-version=v1.5.1
