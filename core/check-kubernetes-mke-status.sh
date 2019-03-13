cd $(dirname $0)

seconds=0
OUTPUT=0
sleep 5
while [ "$OUTPUT" -ne 1 ]; do
  OUTPUT=`dcos kubernetes manager plan status deploy | head -1 | grep -c COMPLETE`;
  seconds=$((seconds+5))
  printf "Waiting for %s seconds for kubernetes mke to come up.\n" "$seconds"
  sleep 5
done
echo "Kubernetes mke is now up and running"
