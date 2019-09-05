export APPNAME=demo
export OSUSER=centos
export MASTERIP=$(dcos node --json | jq --raw-output ".[] | select(.type | test(\"master\")) | .public_ips[0]" | head -1)
export PUBLICIP=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .public_ips[0]" | head -1)
export PUBLICNODES=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .id" | wc -l | awk '{ print $1 }')
#export PUBLICNODES=2
export K8SHOSTNAME=${APPNAME}prodk8scluster1
export KAFKAZOOKEEPERHOSTNAME=${APPNAME}proddataserviceskafka-zookeeper
export KAFKAHOSTNAME=${APPNAME}proddataserviceskafka
export REGISTRYHOSTNAME=${APPNAME}devregistry
export HDFSHOSTNAME=
export SECURE=false
export GPU=false

if [[ ! -z $1 ]]; then
  export MASTERIP=$1
fi

if [[ ! -z $2 ]]; then
  export PUBLICIP=$2
fi

dcos package install --yes --cli dcos-enterprise-cli
../core/download-dcos-ca-cert.sh
../core/deploy-dcos-monitoring.sh infra/monitoring/dcos-monitoring

../core/deploy-kubernetes-mke.sh
../core/check-kubernetes-mke-status.sh

../core/deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1
../core/deploy-registry.sh ${APPNAME}/dev/registry
../core/deploy-gitlab.sh ${APPNAME}/dev/gitlab
../core/deploy-jenkins.sh ${APPNAME}/dev/jenkins
../core/deploy-data-science-engine.sh ${APPNAME}/prod/datascience/data-science-engine-cpu
../core/deploy-kafka-zookeeper.sh ${APPNAME}/prod/dataservices/kafka-zookeeper
../core/check-status-with-name.sh kafka-zookeeper ${APPNAME}/prod/dataservices/kafka-zookeeper

../core/deploy-kafka.sh ${APPNAME}/prod/dataservices/kafka
../core/check-app-status.sh ${APPNAME}/prod/datascience/data-science-engine-cpu

./post-deploy-data-science-engine-flickr.sh

../core/check-status-with-name.sh kafka ${APPNAME}/prod/dataservices/kafka

dcos kafka --name=${APPNAME}/prod/dataservices/kafka topic create -p ${PUBLICNODES} photos

../core/check-app-status.sh ${APPNAME}/dev/registry

../core/check-app-status.sh ${APPNAME}/dev/gitlab

../core/check-app-status.sh ${APPNAME}/dev/jenkins

../core/check-kubernetes-cluster-status.sh ${APPNAME}/prod/k8s/cluster1

../core/check-status-with-name.sh monitoring infra/monitoring/dcos-monitoring

../core/deploy-edgelb.sh infra/network/dcos-edgelb

sleep 10
until dcos edgelb ping; do sleep 1; done
export SERVICEPATH=infra/network/dcos-edgelb
../core/rendertemplate.sh `pwd`/pool-edgelb-all.json.template > `pwd`/pool-edgelb-all.json
dcos edgelb --name=infra/network/dcos-edgelb create pool-edgelb-all.json

../core/check-app-status.sh infra/network/dcos-edgelb/pools/all

./update-etc-hosts.sh

until nc -z -v -w 1 ${APPNAME}.prod.k8s.cluster1.mesos.lab 8443
do
  sleep 1
done

../core/post-deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1
cp ../core/config.$(echo ${APPNAME}/prod/k8s/cluster1 | sed 's/\//-/g') ~/.kube/config
./post-deploy-kubernetes-cluster-flickr.sh ${APPNAME}/prod/k8s/cluster1
./post-deploy-jenkins.sh ${APPNAME}/prod/k8s/cluster1
