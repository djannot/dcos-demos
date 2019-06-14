#!/bin/sh
AGENT=$1
ENDPOINT=$(dcos config show core.dcos_url)
TOKEN=$(dcos config show core.dcos_acs_token)
response=`curl -k $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json"`
if [ "$response" == "{}" ]; then
  cat <<EOF > maintenance.json
{
  "windows" : [
    {
      "machine_ids" : [
        { "hostname" : "$AGENT", "ip" : "$AGENT" }
      ],
      "unavailability" : {
        "start" : { "nanoseconds" : 1 },
        "duration" : { "nanoseconds" : 3600000000000000 }
      }
    }
  ]
}
EOF
else
  curl -k $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json" | jq --arg ip "$AGENT" '.windows[0].machine_ids += [{"hostname": $ip, "ip": $ip}]' > maintenance.json
fi
curl -k $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @maintenance.json
sleep 60
cat <<EOF > down.json
[
 { "hostname" : "$AGENT", "ip" : "$AGENT" }
]
EOF
curl -k $ENDPOINT/mesos/machine/down -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @down.json
