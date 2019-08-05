cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-kafka-zookeeper.json.template > options-kafka-zookeeper.json
dcos package install --yes kafka-zookeeper --options=options-kafka-zookeeper.json --package-version=2.6.0-3.4.14
