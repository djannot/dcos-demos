export APPNAME=smartcity
export PUBLICIP=34.239.79.1
#export PUBLICNODES=$(dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip != null)) | .id" | wc -l | awk '{ print $1 }')
export PUBLICNODES=2
export K8SHOSTNAME=${APPNAME}prodk8scluster1
export HDFSHOSTNAME=${APPNAME}proddataserviceshdfs
export KAFKAZOOKEEPERHOSTNAME=${APPNAME}proddataserviceskafka-zookeeper
export KAFKAHOSTNAME=${APPNAME}proddataserviceskafka
export ELASTICHOSTNAME=${APPNAME}proddataserviceselastic
export SECURE=false

dcos package install --yes --cli dcos-enterprise-cli
../core/download-dcos-ca-cert.sh

../core/deploy-kubernetes-mke.sh
../core/check-kubernetes-mke-status.sh

../core/deploy-elastic.sh ${APPNAME}/prod/dataservices/elastic
../core/deploy-kafka-zookeeper.sh ${APPNAME}/prod/dataservices/kafka-zookeeper
../core/deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1
../core/deploy-cassandra.sh ${APPNAME}/prod/dataservices/cassandra
../core/deploy-gitlab.sh ${APPNAME}/dev/gitlab
../core/deploy-jenkins.sh ${APPNAME}/dev/jenkins
../core/deploy-hdfs.sh ${APPNAME}/prod/dataservices/hdfs
../core/check-status-with-name.sh kafka-zookeeper ${APPNAME}/prod/dataservices/kafka-zookeeper

../core/deploy-kafka.sh ${APPNAME}/prod/dataservices/kafka

../core/check-status-with-name.sh elastic ${APPNAME}/prod/dataservices/elastic

../core/deploy-kibana.sh ${APPNAME}/prod/dataservices/kibana

../core/check-status-with-name.sh hdfs ${APPNAME}/prod/dataservices/hdfs

../core/deploy-jupyterlab.sh ${APPNAME}/prod/datascience/jupyterlab

../core/check-app-status.sh ${APPNAME}/prod/datascience/jupyterlab

../core/post-deploy-jupyterlab.sh ${APPNAME}/prod/datascience/jupyterlab

../core/check-status-with-name.sh kafka ${APPNAME}/prod/dataservices/kafka

../core/check-status-with-name.sh cassandra ${APPNAME}/prod/dataservices/cassandra

../core/check-app-status.sh ${APPNAME}/dev/gitlab

../core/check-app-status.sh ${APPNAME}/dev/jenkins

../core/check-app-status.sh ${APPNAME}/prod/dataservices/kibana

../core/check-kubernetes-cluster-status.sh ${APPNAME}/prod/k8s/cluster1

../core/deploy-edgelb.sh infra/network/dcos-edgelb

sleep 10
until dcos edgelb ping; do sleep 1; done
export SERVICEPATH=infra/network/dcos-edgelb
../core/rendertemplate.sh `pwd`/pool-edgelb-all.json.template > `pwd`/pool-edgelb-all.json
dcos edgelb create pool-edgelb-all.json

../core/check-app-status.sh infra/network/dcos-edgelb/pools/all

./update-etc-hosts.sh

../core/post-deploy-kubernetes-cluster.sh ${APPNAME}/prod/k8s/cluster1
