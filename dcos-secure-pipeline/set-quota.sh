export SERVICEPATH=$1
export SERVICEHOSTNAME=$(echo ${SERVICEPATH} | sed 's/\///g')
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')

curl --cacert ../core/dcos-ca.crt -fsSL -X POST -H "Authorization: token=$(dcos config show core.dcos_acs_token)" -H "Content-Type: application/json" $(dcos config show core.dcos_url)/mesos/quota -d @- <<BODY
{
 "role": "${SERVICEACCOUNT}",
 "guarantee": [
   {
     "name": "cpus",
     "type": "SCALAR",
     "scalar": { "value": 7.0 }
   },
   {
     "name": "mem",
     "type": "SCALAR",
     "scalar": { "value": 49152.0 }
   }
 ]
}
BODY
