cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export URL=$(echo ${SERVICEPATH} | sed 's/\//\./g')

#dcos task exec -i nifi-0-node sh -c 'export JAVA_HOME=$(ls -d $MESOS_SANDBOX/jdk*/jre*/) && export JAVA_HOME=${JAVA_HOME%/} && export PATH=$(ls -d $JAVA_HOME/bin):$PATH && $MESOS_SANDBOX/nifi-toolkit-1.5.0/bin/node-manager.sh -b $MESOS_SANDBOX/bootstrap -d $MESOS_SANDBOX/nifi-1.5.0 -p smartcity.prod.dataservices.nifi.mesos.lab'

token=`curl -X POST -k \
-d 'username=nifiadmin@MESOS.LAB&password=password' \
https://${URL}.mesos.lab:8443/nifi-api/access/token`

users=`curl -X GET -k \
-H "Authorization: Bearer $token" \
https://${URL}.mesos.lab:8443/nifi-api/tenants/users | jq .users[].component.id | sed -e "s/^/{ \"id\": /" | sed -e "s/$/ }/" | sed -e "$ ! s/$/,/"`

admins=$(curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://${URL}.mesos.lab:8443/nifi-api/tenants/user-groups --data-binary @- <<BODY | jq .id | sed -e "s/\"//g"
{
  "revision" : {
    "version" : 0
  },
  "permissions" : {
    "canRead" : true,
    "canWrite" : true
  },
  "component" : {
    "identity" : "admins",
    "users" : [
      $users
    ]
  }
}
BODY)

processgroup=$(curl -X GET -k \
-H "Authorization: Bearer $token" \
https://${URL}.mesos.lab:8443/nifi-api/flow/process-groups/root | jq .processGroupFlow.id | sed -e "s/\"//g")

for action in read write; do
curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://${URL}.mesos.lab:8443/nifi-api/policies --data-binary @- <<BODY
{
  "revision" : {
    "version" : 0
  },
  "component": {
    "resource": "/process-groups/$processgroup",
    "action": "$action",
    "userGroups": [
      { "id": "$admins" }
    ]
  }
}
BODY
done

for action in read write; do
curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://${URL}.mesos.lab:8443/nifi-api/policies --data-binary @- <<BODY
{
  "revision" : {
    "version" : 0
  },
  "component": {
    "resource": "/data/process-groups/$processgroup",
    "action": "$action",
    "userGroups": [
      { "id": "$admins" }
    ]
  }
}
BODY
done
