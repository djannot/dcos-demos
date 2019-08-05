cd $(dirname $0)

dcos security org service-accounts keypair private-${SERVICEACCOUNT}.pem public-${SERVICEACCOUNT}.pem
dcos security org service-accounts show ${SERVICEACCOUNT} > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Deleting the existing service account"
  dcos security org service-accounts delete ${SERVICEACCOUNT}
fi
dcos security org service-accounts create -p public-${SERVICEACCOUNT}.pem -d /${SERVICEPATH} ${SERVICEACCOUNT}
./delete-secret.sh ${SERVICEPATH}/private-${SERVICEACCOUNT}
dcos security secrets create-sa-secret --strict private-${SERVICEACCOUNT}.pem ${SERVICEACCOUNT} /${SERVICEPATH}/private-${SERVICEACCOUNT}
