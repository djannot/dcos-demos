sed "/mesos.lab/d" /etc/hosts > ./hosts
echo "$PUBLICIP ${APPNAME}.prod.k8s.cluster1.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.prod.k8s.cluster2.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.prod.dataservices.nifi.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.prod.dataservices.kibana.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.prod.datascience.jupyterlab.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.dev.gitlab.mesos.lab" >>./hosts
echo "$PUBLICIP ${APPNAME}.dev.jenkins.mesos.lab" >>./hosts
echo "$PUBLICIP infra.storage.portworx.mesos.lab" >>./hosts
sudo mv hosts /etc/hosts
