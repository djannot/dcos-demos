export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

export JENKINSK8STOKEN=$(kubectl --kubeconfig=../core/config.${SERVICEACCOUNT} describe secrets/jenkins-secret | grep "token:" | awk '{ print $2 }')

data=$(cat <<EOF
json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "kubernetes",
    "username": "jenkins",
    "password": "${JENKINSK8STOKEN}",
    "description": "",
    "\$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}
EOF)

curl -k -X POST "https://${APPNAME}.dev.jenkins.mesos.lab:8443/credentials/store/system/domain/_/createCredentials" \
--data-urlencode "${data}"

curl -k -X POST "https://${APPNAME}.dev.jenkins.mesos.lab:8443/credentials/store/system/domain/_/createCredentials" \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "gitlab",
    "username": "root",
    "password": "password",
    "description": "",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'
