cat principals.txt | while read principal; do
  echo "ADDING principal $principal"
  until echo password | dcos task exec -i kdc kadmin -p admin/admin -q "addprinc -pw password $principal"
  do
    echo "Retrying"
  done
done
