cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:app_id:/${SERVICEPATH} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation:principal:${SERVICEACCOUNT} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:volume:principal:${SERVICEACCOUNT} create

./rendertemplate.sh options-elastic.json.template > options-elastic.json
dcos package install --yes elastic --options=options-elastic.json --package-version=3.0.0-7.3.2
