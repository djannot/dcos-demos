cd $(dirname $0)

export SERVICEPATH=$1

./create-signed-certificate.sh ${REGISTRYHOSTNAME}.marathon.l4lb.thisdcos.directory
./delete-secret.sh signed-key
dcos security secrets create signed-key --file signed.key
./delete-secret.sh signed-certificate
dcos security secrets create signed-certificate --file signed.certificate
./deploy-certificatesforregistry.sh

./rendertemplate.sh marathon-registry.json.template > marathon-registry.json

dcos marathon app add marathon-registry.json

./update-docker-for-registry.sh ${REGISTRYHOSTNAME}.marathon.l4lb.thisdcos.directory
