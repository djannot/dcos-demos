cd $(dirname $0)

export SERVICEPATH=registry
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

./rendertemplate.sh options-package-registry.json.template > options-package-registry.json
dcos package install --yes package-registry --options=options-package-registry.json

../core/check-app-status.sh registry

dcos package repo add --index=0 Registry https://registry.marathon.l4lb.thisdcos.directory/repo

# Packages available at https://downloads.mesosphere.com/universe/packages/packages.html
# wget https://downloads.mesosphere.com/universe/packages/kubernetes-cluster/2.2.2-1.13.5/kubernetes-cluster-2.2.2-1.13.5.dcos
# dcos registry add --dcos-file kubernetes-cluster-2.2.2-1.13.5.dcos
