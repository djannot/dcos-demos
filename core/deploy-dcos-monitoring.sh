cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-dcos-monitoring.json.template > options-dcos-monitoring.json

dcos package install dcos-monitoring --yes --options=options-dcos-monitoring.json --package-version=v1.2.0
