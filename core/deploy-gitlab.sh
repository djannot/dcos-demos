cd $(dirname $0)

export SERVICEPATH=$1

./rendertemplate.sh marathon-gitlab.json.template > marathon-gitlab.json

dcos marathon app add marathon-gitlab.json
