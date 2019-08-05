cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEHOSTNAME=$(echo ${SERVICEPATH} | sed 's/\///g')
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

./create-service-account.sh
./grant-permissions.sh

#dcos security org users delete user1
#dcos security org users create -p password user1
#dcos security org users grant user1 dcos:adminrouter:package full
#dcos security org users grant user1 dcos:secrets:default:/${SERVICEPATH}/tgt full
#dcos security org users grant user1 dcos:adminrouter:ops:historyservice full

./delete-secret.sh ${SERVICEPATH}/keytab
dcos security secrets create ${SERVICEPATH}/keytab --file merged.keytab
./delete-secret.sh ${SERVICEPATH}/truststore
dcos security secrets create ${SERVICEPATH}/truststore --file trust.jks
./delete-secret.sh ${SERVICEPATH}/truststore-password
dcos security secrets create ${SERVICEPATH}/truststore-password -v changeit
./delete-secret.sh ${SERVICEPATH}/keystore
dcos security secrets create ${SERVICEPATH}/keystore --file server.jks
./delete-secret.sh ${SERVICEPATH}/keystore-password
dcos security secrets create ${SERVICEPATH}/keystore-password -v changeit
./delete-secret.sh ${SERVICEPATH}/key-password
dcos security secrets create ${SERVICEPATH}/key-password -v changeit
./delete-secret.sh ${SERVICEPATH}/truststore-ca
dcos security secrets create ${SERVICEPATH}/truststore-ca --file trust-ca.jks
./delete-secret.sh ${SERVICEPATH}/jaas
dcos security secrets create ${SERVICEPATH}/jaas --file jaas.conf
#dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:list:default:/ full
#dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:default:/truststore read
#dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:default:/truststore-ca read
#dcos security org users grant ${SERVICEACCOUNT} dcos:secrets:default:/keystore read

dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:rw full
dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:ca:ro full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:user:nobody create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role:${SERVICEACCOUNT} create
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:task:app_id:/${SERVICEPATH} create

dcos package repo remove data-science-engine
dcos package repo add --index=0 data-science-engine 'https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/autodelete7d/data-science-engine/20190801-145001-tVZGaowDAkuwUMVB/stub-universe-data-science-engine.json'

if [ ! -z "$2" ] && $2; then
  ./rendertemplate.sh options-data-science-engine-gpu.json.template > options-data-science-engine.json
else
  if [[ ! -z ${HDFSHOSTNAME} ]]; then
    ./rendertemplate.sh options-data-science-engine.json.template > options-data-science-engine.json
  else
    ./rendertemplate.sh options-data-science-engine.json.template.nohdfs > options-data-science-engine.json
  fi
fi
dcos package install --yes data-science-engine --options=options-data-science-engine.json
