cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEHOSTNAME=$(echo ${SERVICEPATH} | sed 's/\///g')
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

./create-service-account.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:* create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:user:root create

./rendertemplate.sh options-jenkins.json.template > options-jenkins.json
dcos package install --yes jenkins --options=options-jenkins.json --package-version=3.6.0-2.190.1
