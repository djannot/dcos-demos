cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-hdfs.json.template > options-hdfs.json
dcos package install --yes hdfs --options=options-hdfs.json --package-version=2.6.0-3.2.0
