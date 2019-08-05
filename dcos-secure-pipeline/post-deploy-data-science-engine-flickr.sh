../core/rendertemplate.sh `pwd`/serve-model/Jenkinsfile.template > `pwd`/serve-model/Jenkinsfile
if ${SECURE}; then
  ../core/rendertemplate.sh `pwd`/serve-model/serve-model.py.template.secure > `pwd`/serve-model/serve-model.py
  ../core/rendertemplate.sh `pwd`/serve-model/serve-model.yaml.template.secure > `pwd`/serve-model/serve-model.yaml
else
  ../core/rendertemplate.sh `pwd`/serve-model/serve-model.py.template > `pwd`/serve-model/serve-model.py
  ../core/rendertemplate.sh `pwd`/serve-model/serve-model.yaml.template > `pwd`/serve-model/serve-model.yaml
  ../core/rendertemplate.sh `pwd`/get-flickr-photos.ipynb.template > `pwd`/get-flickr-photos.ipynb
fi

task=`dcos task | grep data-science-engine-cpu | awk '{ print $5 }'`
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model'
if ${SECURE}; then
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Dockerfile' < ./serve-model/Dockerfile.secure
else
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Dockerfile' < ./serve-model/Dockerfile
fi
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Jenkinsfile' < ./serve-model/Jenkinsfile
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.py' < ./serve-model/serve-model.py
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.yaml' < ./serve-model/serve-model.yaml
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model/templates'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/main.html' < ./serve-model/templates/main.html
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/response.html' < ./serve-model/templates/response.html

if ! ${SECURE}; then
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/output_graph.pb' < ./serve-model/output_graph.pb
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/output_labels.txt' < ./serve-model/output_labels.txt
  dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/get-flickr-photos.ipynb' < ./get-flickr-photos.ipynb
fi
