cd $(dirname $0)

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date

./rendertemplate.sh ./fluent-bit.conf.master.template > ./fluent-bit.conf.master
# All masters
dcos node --json | jq --raw-output ".[] | select(.type | test(\"agent\") == false) | .public_ips[0]" | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo yum -y install nc'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mkdir -p /etc/fluent-bit'
  scp -o ProxyCommand="ssh ${OSUSER}@${MASTERIP} nc $ip 22" ./fluent-bit.conf.master ${OSUSER}@$ip:/home/centos/fluent-bit.conf
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mv /home/centos/fluent-bit.conf /etc/fluent-bit/fluent-bit.conf'
done

./rendertemplate.sh ../core/fluent-bit.conf.agent.template > ../core/fluent-bit.conf.agent
# All agents
dcos node --json | jq --raw-output ".[] | select(.type | test(\"agent\")) | .public_ips[0]" | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mkdir -p /etc/fluent-bit'
  scp -o ProxyCommand="ssh ${OSUSER}@${MASTERIP} nc $ip 22" ./fluent-bit.conf.agent ${OSUSER}@$ip:/home/centos/fluent-bit.conf
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mv /home/centos/fluent-bit.conf /etc/fluent-bit/fluent-bit.conf'
done

# All nodes
dcos node --json | jq --raw-output ".[] | .public_ips[0]" | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'echo "FLUENT_BIT_CONFIG_FILE=/etc/fluent-bit/fluent-bit.conf" > /home/centos/fluent-bit.env'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mv /home/centos/fluent-bit.env /etc/fluent-bit/fluent-bit.env'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mkdir -p /etc/systemd/system/dcos-fluent-bit.service.d'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'echo "[Service]" > /home/centos/override.conf'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'echo "EnvironmentFile=/etc/fluent-bit/fluent-bit.env" >> /home/centos/override.conf'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo mv /home/centos/override.conf /etc/systemd/system/dcos-fluent-bit.service.d/override.conf'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo systemctl daemon-reload'
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'sudo systemctl restart dcos-fluent-bit.service'
done
