export APPNAME=poc
export PUBLICIP=34.207.100.220
export PUBLICNODES=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .id" | wc -l | awk '{ print $1 }')
export PRIVATENODES=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .id" | wc -l | awk '{ print $1 }')
export K8SHOSTNAME=${APPNAME}prodk8scluster1
export HDFSHOSTNAME=${APPNAME}proddataserviceshdfs
export KAFKAZOOKEEPERHOSTNAME=${APPNAME}proddataserviceskafka-zookeeper
export KAFKAHOSTNAME=${APPNAME}proddataserviceskafka
export ELASTICHOSTNAME=${APPNAME}proddataserviceselastic
export SECURE=false
export K8SLBPORT=6379
export K8SINGRESSPORT=8080
export K8SISTIOPORT=80

dcos package install --yes --cli dcos-enterprise-cli
../core/download-dcos-ca-cert.sh

../core/deploy-portworx.sh infra/storage/portworx
../core/check-status-with-name.sh portworx infra/storage/portworx

../core/deploy-kubernetes-mke.sh
../core/check-kubernetes-mke-status.sh

../core/deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1 true 2.2.2-1.13.5
../core/check-kubernetes-cluster-status.sh ${APPNAME}/prod/k8s/cluster1

../core/deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster2 false
../core/check-kubernetes-cluster-status.sh ${APPNAME}/prod/k8s/cluster2

dcos kubernetes cluster update --cluster-name=${APPNAME}/prod/k8s/cluster1 --package-version=2.3.3-1.14.3 --yes

../core/deploy-edgelb.sh infra/network/dcos-edgelb

sleep 10
until dcos edgelb ping; do sleep 1; done
export SERVICEPATH=infra/network/dcos-edgelb
../core/rendertemplate.sh `pwd`/pool-edgelb-all.json.template > `pwd`/pool-edgelb-all.json
dcos edgelb create pool-edgelb-all.json

../core/check-app-status.sh infra/network/dcos-edgelb/pools/all

./update-etc-hosts.sh

../core/post-deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1
cp ../core/config.$(echo ${APPNAME}/prod/k8s/cluster1 | sed 's/\//-/g') ~/.kube/config

 ./k8s-service-type-load-balancer-test.sh

# telnet $PUBLICIP 6379
# quit

./k8s-ingress-test.sh

curl -H "Host: http-echo-1.com" http://${PUBLICIP}:8080
curl -H "Host: http-echo-2.com" http://${PUBLICIP}:8080

./deploy-helm.sh

./deploy-istio.sh

./deploy-istio-app-test.sh

open http://${PUBLICIP}:${K8SISTIOPORT}/productpage

# Refresh the page several times to see the reviews part changing

../core/deploy-gitlab.sh ${APPNAME}/dev/gitlab
../core/check-app-status.sh ${APPNAME}/dev/gitlab

# You probably need to redeploy the EdgeLB pool

open https://poc.dev.gitlab.mesos.lab:8443

../core/deploy-jenkins.sh ${APPNAME}/dev/jenkins
../core/check-app-status.sh ${APPNAME}/dev/jenkins

open https://poc.dev.jenkins.mesos.lab:8443

# TODO Create a CI/CD test

../core/deploy-kafka-zookeeper.sh ${APPNAME}/prod/dataservices/kafka-zookeeper
../core/check-status-with-name.sh kafka-zookeeper ${APPNAME}/prod/dataservices/kafka-zookeeper

../core/deploy-kafka.sh ${APPNAME}/prod/dataservices/kafka
../core/check-status-with-name.sh kafka ${APPNAME}/prod/dataservices/kafka

# TODO Create a Kafka test

../core/deploy-elastic.sh ${APPNAME}/prod/dataservices/elastic
../core/check-status-with-name.sh elastic ${APPNAME}/prod/dataservices/elastic

../core/deploy-kibana.sh ${APPNAME}/prod/dataservices/kibana
../core/check-app-status.sh ${APPNAME}/prod/dataservices/kibana

open https://poc.prod.dataservices.kibana.mesos.lab:8443

# TODO Create a Kibana example (DC/OS logs ?)

../core/deploy-cassandra.sh ${APPNAME}/prod/dataservices/cassandra
../core/check-status-with-name.sh cassandra ${APPNAME}/prod/dataservices/cassandra

# TODO Create a Cassandra test

../core/deploy-hdfs.sh ${APPNAME}/prod/dataservices/hdfs
../core/check-status-with-name.sh hdfs ${APPNAME}/prod/dataservices/hdfs

../core/deploy-jupyterlab.sh ${APPNAME}/prod/datascience/jupyterlab
../core/check-app-status.sh ${APPNAME}/prod/datascience/jupyterlab

../core/post-deploy-jupyterlab.sh ${APPNAME}/prod/datascience/jupyterlab

open https://poc.prod.datascience.jupyterlab.mesos.lab:8443
