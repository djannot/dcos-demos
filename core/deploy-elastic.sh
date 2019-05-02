cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-elastic.json.template > options-elastic.json
dcos package install --yes elastic --options=options-elastic.json --package-version=2.6.0-6.6.1
