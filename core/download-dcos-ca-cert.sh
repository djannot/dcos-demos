cd $(dirname $0)

curl -k -v $(dcos config show core.dcos_url)/ca/dcos-ca.crt -o dcos-ca.crt
openssl x509 -in dcos-ca.crt -inform pem -out dcos-ca.der -outform der
rm -f trust-ca.jks
keytool -importcert -alias startssl -keystore trust-ca.jks -storepass changeit -file dcos-ca.der -noprompt
./delete-secret.sh truststore-ca
dcos security secrets create /truststore-ca --file trust-ca.jks
