cat principals.txt | while read principal; do
  echo "CREATING keytab for the principal $principal"
  file=`echo $principal | sed 's/\//\./' | sed 's/@/\./'`
  echo password | dcos task exec -i kdc kadmin -p admin/admin -q "xst -k $file $principal"
done
