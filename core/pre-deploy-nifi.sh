cd $(dirname $0)

export SERVICEPATH=$1

rm -f nifi.config-secret
trustca=$(base64 trust-ca.jks | tr -d \\n)
echo "#!/bin/bash" >> nifi.config-secret
echo "cat > trust-ca.jks.base64 << EOF" >> nifi.config-secret
echo $trustca >> nifi.config-secret
echo EOF >> nifi.config-secret
echo "cat > appdef << EOF" >> nifi.config-secret
cat appdef.${APPNAME} >> nifi.config-secret
echo EOF >> nifi.config-secret
echo "base64 --decode /mnt/mesos/sandbox/trust-ca.jks.base64 > /mnt/mesos/sandbox/trust-ca.jks" >> nifi.config-secret
cat curl.function >> nifi.config-secret
echo "__curl http://api.${HDFSHOSTNAME}.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml > /mnt/mesos/sandbox/core-site.xml" >> nifi.config-secret
echo "__curl http://api.${HDFSHOSTNAME}.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml > /mnt/mesos/sandbox/hdfs-site.xml" >> nifi.config-secret
dcos security secrets delete ${SERVICEPATH}/config-secret
dcos security secrets create ${SERVICEPATH}/config-secret --file nifi.config-secret
