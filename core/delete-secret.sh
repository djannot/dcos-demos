cd $(dirname $0)

test=$(dcos security secrets list / | grep -c $1)
if [ $test -ne 0 ]; then
  echo "Deleting the existing secret $1"
  dcos security secrets delete $1
fi
