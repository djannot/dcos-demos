cd $(dirname $0)

eval "cat <<EOF
$(<$1)
EOF
"
