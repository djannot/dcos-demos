cd $(dirname $0)

dcos security org users grant dcos_marathon dcos:mesos:master:task:user:root create

dcos marathon app add marathon-certificatesforregistry.json
sleep 30
./check-app-status.sh certificatesforregistry
