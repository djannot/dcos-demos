cd $(dirname $0)

fqdn=$1

request=$(cat <<EOF
{
   "CN": "$fqdn",
   "key": {"algo": "rsa", "size": 4096},
   "hosts": ["$fqdn"]
}
EOF)

newkey=$(curl -k $(dcos config show core.dcos_url)/ca/api/v2/newkey \
  -X POST \
  -H 'content-type:application/json'  \
  -d "${request}" \
  -H "Authorization: token=$(dcos config show core.dcos_acs_token)")

echo $newkey | jq --raw-output .result.private_key > signed.key

csr=$(echo $newkey | jq .result.certificate_request)

curl -k $(dcos config show core.dcos_url)/ca/api/v2/sign \
  -X POST \
  -H 'content-type:application/json'  \
  -d "{\"certificate_request\": ${csr}}" \
  -H "Authorization: token=$(dcos config show core.dcos_acs_token)" | jq --raw-output .result.certificate > signed.certificate
