#!/bin/sh
AGENT=$1
DCOS_USER=admin
DCOS_PASSWORD=password
ENDPOINT=https://172.25.8.173
TOKEN=$(curl -k -H "Content-Type: application/json" -X POST -d "{\"uid\": \"${DCOS_USER}\", \"password\": \"${DCOS_PASSWORD}\"}" $ENDPOINT/acs/api/v1/auth/login | grep token | cut -d\" -f4)
response=`curl $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json"`
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
  curl $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json" | jq --arg ip "$AGENT" '.windows[0].machine_ids += [{"hostname": $ip, "ip": $ip}]' > maintenance.json
fi
curl $ENDPOINT/mesos/maintenance/schedule -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @maintenance.json
sleep 60
cat <<EOF > down.json
[
 { "hostname" : "$AGENT", "ip" : "$AGENT" }
]
EOF
curl $ENDPOINT/mesos/machine/down -H "Authorization: token=$TOKEN" -H "Content-type: application/json" -X POST -d @down.json
