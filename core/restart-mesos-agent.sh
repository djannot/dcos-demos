# To run on the agent after entering maintenance mode
sh -c 'systemctl kill -s SIGUSR1 dcos-mesos-slave && systemctl stop dcos-mesos-slave'
systemctl daemon-reload
rm -f /var/lib/mesos/slave/meta/slaves/latest
rm -f /var/lib/dcos/mesos-resources
systemctl start dcos-mesos-slave
# Now, you can exit maintenance mode
