cd $(dirname $0)

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date
dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .public_ips[0]" | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo yum -y install krb5-workstation'
done
