cd $(dirname $0)

./rendertemplate.sh principals.txt.template > principals.txt

dcos security org users grant dcos_marathon dcos:mesos:master:task:user:root create

# Deploy a kdc on Marathon. In a real world environment, we would probably use an existing AD
dcos marathon app add marathon-kdc.json
sleep 30
./check-app-status.sh kdc

# Create all the Kerberos principals needed for HDFS, Kafka, ...
./create-principals.sh

# Create a keytab for them
./create-keytabs.sh
./merge-keytabs.sh

# Create the secret for the keytab file
dcos security secrets delete keytab
dcos security secrets create keytab --file merged.keytab
dcos security secrets delete krb5
dcos security secrets create krb5 --file krb5.conf
