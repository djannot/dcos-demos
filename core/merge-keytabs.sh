echo > commands.txt
cat principals.txt | while read principal; do
  file=`echo $principal | sed 's/\//\./' | sed 's/@/\./'`
  printf "read_kt $file\n" >> commands.txt
done
printf "list\nwrite_kt merged.keytab\nquit\n" >> commands.txt
cat commands.txt
dcos task exec -i kdc sh -c 'cat > ./commands.txt' < ./commands.txt
dcos task exec -i kdc ktutil < ./commands.txt
dcos task exec -i kdc sh -c 'base64 -i merged.keytab -w 0 > merged.keytab.base64'
dcos task exec -i kdc cat merged.keytab.base64 > merged.keytab.base64
#tail -n +2 merged.keytab.base64.tmp > merged.keytab.base64
#rm -f merged.keytab.base64.tmp
#base64 --decode merged.keytab.base64 > merged.keytab
base64 --decode merged.keytab.base64 > merged.keytab
