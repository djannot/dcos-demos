cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-kibana.json.template > options-kibana.json
dcos package install --yes kibana --options=options-kibana.json --package-version=3.0.0-7.3.2
