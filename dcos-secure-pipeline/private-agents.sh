cd $(dirname $0)

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date
dcos node list | grep -v HOSTNAME | grep -v master | awk '{ print $2 }' | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo yum -y install krb5-workstation'
done
