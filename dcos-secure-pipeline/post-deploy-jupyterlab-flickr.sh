../core/rendertemplate.sh `pwd`/serve-model/Jenkinsfile.template > `pwd`/serve-model/Jenkinsfile
../core/rendertemplate.sh `pwd`/serve-model/serve-model.yaml.template > `pwd`/serve-model/serve-model.yaml

task=`dcos task | grep jupyterlab | awk '{ print $5 }'`
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Dockerfile' < ./serve-model/Dockerfile
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.py' < ./serve-model/serve-model.py
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.yaml' < ./serve-model/serve-model.yaml
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Jenkinsfile' < ./serve-model/Jenkinsfile
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model/templates'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/response.html' < ./serve-model/templates/response.html

#dcos task exec -i $task sh -c 'JAVA_HOME=/opt/jdk /opt/hadoop/bin/hdfs dfs -ls -R /user/nobody/flickr | wc -l'
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git config --global user.name "Administrator"'
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git config --global user.email "admin@example.com"'
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git init'
#dcos task exec -i $task sh -c "cd /mnt/mesos/sandbox/serve-model && git remote add origin http://${APPNAME}devgitlab.marathon.l4lb.thisdcos.directory/root/serve-model.git"
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git add .'
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git commit -a -m "First commit"'
#dcos task exec -i $task sh -c 'cd /mnt/mesos/sandbox/serve-model && git push -u origin master'
