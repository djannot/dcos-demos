cd $(dirname $0)

seconds=0
OUTPUT=0
sleep 5
while [ "$OUTPUT" -ne 1 ]; do
  OUTPUT=`dcos marathon app list | grep $1 | awk '{print $4}' | cut -c1`;
  seconds=$((seconds+5))
  printf "Waiting for %s seconds for $1 to come up.\n" "$seconds"
  sleep 5
done
echo "Service $1 is now up and running"
