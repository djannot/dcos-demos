../core/rendertemplate.sh `pwd`/serve-model/Jenkinsfile.template > `pwd`/serve-model/Jenkinsfile
../core/rendertemplate.sh `pwd`/serve-model/serve-model.yaml.template > `pwd`/serve-model/serve-model.yaml

task=`dcos task | grep jupyterlab | awk '{ print $5 }'`
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Dockerfile' < ./serve-model/Dockerfile
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.py' < ./serve-model/serve-model.py
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.yaml' < ./serve-model/serve-model.yaml
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model/templates'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/main.html' < ./serve-model/templates/main.html
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/response.html' < ./serve-model/templates/response.html
