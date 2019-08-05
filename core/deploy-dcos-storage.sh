cd $(dirname $0)

export SERVICEPATH=$1
export SERVICEACCOUNT=$(echo ${SERVICEPATH} | sed 's/\//-/g')
export ROLE=$(echo ${SERVICEPATH} | sed 's/\//__/g')-role

./create-service-account.sh
./grant-permissions.sh

dcos security org users grant ${SERVICEACCOUNT} dcos:adminrouter:ops:slave full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:principal:${SERVICEACCOUNT} full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:framework:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation delete
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:reservation:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:block_disk:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:mount_disk:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:master:raw_disk:role full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:agent:endpoint:path:/api/v1 full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:agent:resource_provider_config full
dcos security org users grant ${SERVICEACCOUNT} dcos:mesos:agent:resource_provider read

./rendertemplate.sh options-dcos-storage.json.template > options-dcos-storage.json

dcos package install package-registry --cli --yes
dcos registry activate
dcos registry add --dcos-file storage-v1.0.0.dcos

dcos package install storage --yes --options=options-dcos-storage.json

sleep 10

dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .id" | while read id; do
  cat > devices-provider.json <<EOF
{
    "name": "${id}",
    "description": "Expose devices on a node",
    "spec": {
        "plugin": {
            "name": "devices",
            "config-version": "latest"
        },
        "node": "${id}",
        "plugin-configuration": {
            "blacklist": "loop[0-9]"
        }
    }
}
EOF
  dcos storage provider create devices-provider.json
done

dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .id" | while read id; do
  dcos storage device list --node=${id}
done

dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .id" | while read id; do
  cat > volume-group-1.json <<EOF
{
    "name": "volume-group-${id}",
    "description": "The primary volume group",
    "spec": {
        "plugin": {
            "name": "lvm",
            "config-version": "latest"
        },
        "node": "$id",
        "plugin-configuration": {
            "devices": ["xvdf"]
        },
        "labels": {"rotational": "false"}
    }
}
EOF
  dcos storage provider create volume-group-1.json
done

dcos storage provider list

cat > fast.json <<EOF
{
    "name": "fast",
    "description": "Fast SSD disks",
    "spec": {
        "provider-selector": {
            "plugin": "lvm",
            "matches": {
                "labels": {
                    "rotational": "false"
                }
            }
        },
        "mount": {
            "filesystem": "xfs"
        }
    }
}
EOF
dcos storage profile create fast.json

dcos storage profile list

dcos node --json | jq --raw-output ".[] | select((.type | test(\"agent\")) and (.attributes.public_ip == null)) | .id" | head -2 | while read id; do
  dcos storage volume create --name cassandra-volume-${id} --capacity 10240M --profile fast --node ${id}
done
