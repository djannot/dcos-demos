cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-cassandra.json.template > options-cassandra.json
dcos package install --yes cassandra --options=options-cassandra.json --package-version=2.4.0-3.0.16
