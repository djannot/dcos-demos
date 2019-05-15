#!/bin/sh
AGENT=$1
DCOS_USER=admin
DCOS_PASSWORD=password
ENDPOINT=https://172.25.8.173
TOKEN=$(curl -k -H "Content-Type: application/json" -X POST -d "{\"uid\": \"${DCOS_USER}\", \"password\": \"${DCOS_PASSWORD}\"}" $ENDPOINT/acs/api/v1/auth/login | grep token | cut -d\" -f4)
cat <<EOF > up.json
[
 { "hostname" : "$AGENT", "ip" : "$AGENT" }
]
EOF
curl $ENDPOINT/mesos/machine/up -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @up.json
