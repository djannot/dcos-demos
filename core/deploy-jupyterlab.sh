cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEHOSTNAME=$(echo ${SERVICEPATH} | sed 's/\///g')
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

./create-service-account.sh

dcos security org users delete user1
dcos security org users create -p password user1
dcos security org users grant user1 dcos:adminrouter:package full
dcos security org users grant user1 dcos:secrets:default:/${SERVICEPATH}/tgt full
dcos security org users grant user1 dcos:adminrouter:ops:historyservice full

dcos security secrets create /truststore --file trust.jks
dcos security secrets create /keystore --file server.jks

dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:rw full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:ro full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:user:nobody create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:${SERVICEACCOUNT} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:app_id:/${SERVICEPATH} create

./rendertemplate.sh marathon-jupyterlab.json.template > marathon-jupyterlab.json
dcos marathon app add marathon-jupyterlab.json
