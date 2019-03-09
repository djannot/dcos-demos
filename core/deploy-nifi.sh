cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export URL=$(echo ${SERVICEPATH} | sed 's/\//\./g')

dcos security secrets create -v password nifiadminpassword

./create-service-account.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:superuser full --description "grant permission to superuser"

./rendertemplate.sh options-nifi.json.template > options-nifi.json
dcos package install --yes nifi --options=options-nifi.json --package-version=0.3.0-1.7.1
