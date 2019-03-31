cd $(dirname $0)

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date
dcos node | grep -v HOSTNAME | grep -v master | awk '{ print $2 }' | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo mkdir -p /etc/docker/certs.d/$1:5000
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo ls /etc/docker/certs.d/
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo curl -k -o /etc/docker/certs.d/$1:5000/ca.crt $(dcos config show core.dcos_url)/ca/dcos-ca.crt
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo ls /etc/docker/certs.d/$1:5000
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo systemctl restart docker
done
