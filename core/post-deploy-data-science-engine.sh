cd $(dirname $0)

export SERVICEPATH=$1

task=`dcos task | grep $(echo ${SERVICEPATH} | sed 's/\//_/g') | awk '{ print $5 }'`
if ${SECURE}; then
  dcos task exec -i $task sh -c 'echo spark.files /tmp/krb5cc_99,/mnt/mesos/sandbox/executors/jaas.conf >> /opt/spark/conf/spark-defaults.conf'
  dcos task exec -i $task sh -c 'echo spark.executorEnv.KRB5CCNAME /mnt/mesos/sandbox/krb5cc_99 >> /opt/spark/conf/spark-defaults.conf'
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/jaas.conf' < ./jaas.conf
  dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/executors'
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/executors/jaas.conf' < ./jaas-executors.conf
fi
