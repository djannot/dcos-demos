cd $(dirname $0)

if ${SECURE}; then
eval "cat <<EOF
$(<$1.secure)
EOF
"
else
eval "cat <<EOF
$(<$1)
EOF
"
fi
