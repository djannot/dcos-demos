cd $(dirname $0)

dcos package repo remove Universe

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} curl -v https://downloads.mesosphere.com/universe/public/local-universe.tar.gz -o local-universe.tar.gz
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} curl -v https://raw.githubusercontent.com/mesosphere/universe/version-3.x/docker/local-universe/dcos-local-universe-http.service -o dcos-local-universe-http.service
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} curl -v https://raw.githubusercontent.com/mesosphere/universe/version-3.x/docker/local-universe/dcos-local-universe-registry.service -o dcos-local-universe-registry.service
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo mv dcos-local-universe-registry.service /etc/systemd/system/
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo mv dcos-local-universe-http.service /etc/systemd/system/
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} 'sudo docker load < local-universe.tar.gz'
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo systemctl daemon-reload
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo systemctl enable dcos-local-universe-http
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo systemctl enable dcos-local-universe-registry
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo systemctl start dcos-local-universe-http
ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} sudo systemctl start dcos-local-universe-registry

ssh -n -o "StrictHostKeyChecking no" ${OSUSER}@${MASTERIP} date
dcos node | grep -v HOSTNAME | grep -v master | awk '{ print $2 }' | while read ip; do
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo mkdir -p /etc/docker/certs.d/master.mesos:5000
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo curl -o /etc/docker/certs.d/master.mesos:5000/ca.crt http://master.mesos:8082/certs/domain.crt
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo systemctl restart docker
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip sudo cp /etc/docker/certs.d/master.mesos:5000/ca.crt /var/lib/dcos/pki/tls/certs/docker-registry-ca.crt
  ssh -n -o "StrictHostKeyChecking no" -J ${OSUSER}@${MASTERIP} ${OSUSER}@$ip 'cd /var/lib/dcos/pki/tls/certs/ && hash=$(openssl x509 -hash -noout -in docker-registry-ca.crt) && sudo ln -s /var/lib/dcos/pki/tls/certs/docker-registry-ca.crt /var/lib/dcos/pki/tls/certs/${hash}.0'
done

dcos package repo add local-universe http://master.mesos:8082/repo
