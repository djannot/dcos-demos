cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:app_id:/${SERVICEPATH} create
dcos security org users grant dcos_marathon dcos:mesos:master:task:user:nobody create

./rendertemplate.sh options-spark.json.template > options-spark.json
dcos package install --yes spark --options=options-spark.json --package-version=2.8.0-2.4.0
