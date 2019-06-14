#!/bin/sh
AGENT=$1
ENDPOINT=$(dcos config show core.dcos_url)
TOKEN=$(dcos config show core.dcos_acs_token)
cat <<EOF > up.json
[
 { "hostname" : "$AGENT", "ip" : "$AGENT" }
]
EOF
curl -k $ENDPOINT/mesos/machine/up -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @up.json
