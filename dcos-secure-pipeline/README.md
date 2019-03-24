# DC/OS Secure ML Pipeline

In this demo, I've used Apache NiFi to get some pictures of cats and dogs from the Flickr API, stored them in HDFS, retrained a Tensorflow model to classify these new categories and used a CI/CD pipeline (using Gitlab and Jenkins) to deploy on Kubernetes a web application leveraging this model.

## Prerequisites

You need to provision a DC/OS Enterprise Edition cluster in either `permissive` or `strict` mode.

A DC/OS cluster with at least 10 private agents providing 40 CPU and 128 GB of RAM is required.

If you deploy it in strict mode, you need to setup the DCOS cli using `https` (dcos cluster setup `https://`).


## Deployment

You simply need to execute the following command:

```
./install.sh
```

It will deploy Apache HDFS, Kafka (with its own dedicated ZooKeeper), Spark, NiFi and Jupyter with Kerberos and TLS.

A `KDC` will also be deployed, but if you'd like to reuse the same approach to deploy this stack in production, you would skip this step and use your own KDC (which could be Active Directory, for example).

## demo script

Run the following command to launch NiFi in your web browser:

```
./open-nifi.sh
```

Login with `nifiadmin@MESOS.LAB` using the password `password`.

![nifi](images/nifi.png)

Right click on the background.

![nifi-templates](images/nifi-templates.png)

Select `Upload template` and upload the `Flickr.xml` template.

![nifi-upload-template-flickr](images/nifi-upload-template-flickr.png)

Drag and drop the template icon and select the `Flickr.xml` template.

![nifi-add-template-flickr](images/nifi-add-template-flickr.png)

As you can see, there are few warnings. They are corresponding to the sensitive information that can't be stored in a template.

![nifi-template-flickr](images/nifi-template-flickr.png)

Double click on the `Get Cat Pictures from Flickr` group.

![nifi-get-recent-flickr-pictures](images/nifi-get-cat-pictures-from-flickr.png)

Double click on the first `InvokeHTTP` processor.

![nifi-invoke-http](images/nifi-invoke-http.png)

Then, click on the arrow in the `SSL Context Service` row.

![nifi-invoke-http-ssl](images/nifi-invoke-http-ssl.png)

Click on the `Configure` icon.

![nifi-invoke-http-ssl-password](images/nifi-invoke-http-ssl-password.png)

Indicate `changeit` for the truststore password.

![nifi-invoke-http-ssl-enable](images/nifi-invoke-http-ssl-enable.png)

Click on the `Enable` icon and enable it.

Double click on the `PublishKafka_1_0` processor.

Configure and enable the `SSL Context Service` the same way you did on the previous step.

Go back to the main screen by clicking on `NiFi Flow` on the bottom left.

Double click on the `Get Dog Pictures from Flickr` group.

Double click on the `PublishKafka_1_0` processor.

Configure and enable the `SSL Context Service` the same way you did on the previous step.

Go back to the main screen by clicking on `NiFi Flow` on the bottom left.

Select all the components and click on the play button.

Run the following command to launch the Jupyter notebook in your web browser:

```
./open-jupyterlab.sh
```

The password is `jupyter`

![jupyter-launcher](images/jupyter-launcher.png)

Click on the `Terminal` icon to launch a terminal inside the Notebook.

Run the following command until you get around 2000 results (which means 2000 pictures) and stop the NiFi workflow.

```
hdfs dfs -ls -R /user/nobody/flickr | wc -l
2000
```

Go to `~/serve-model` and edit the Jenkins file to update the value of the token which the one that has been returned by the deployment script:

```
Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImplbmtpbnMtc2VjcmV0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImplbmtpbnMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyZjAwNGRiMS1jMTkzLTExZTgtYjBjMS0wNjE0ZmVlYTljMjAiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpqZW5raW5zIn0.SBk2PXirHMgzQufznAp7hq7KZ53wXrzmnqJ1IzUKosYggGuTaCLIquPwZt765fzfoCIjyVtR0EJB-drlQQeU8CC1MiuYtUoFHNWW3ArOIw54uk50mtaoFHkY2N1Cte_rSFp45Tq6MqC5O41TmjlekkQ3AhFjTGArfZHtd5vayzk1fKYVLd69DF26NuXqrgPH0agnXQ02TL6jhGdHj1Ptnm50CbkGyfIWLG4zfzKTa_mPirjBXfxKn7yJKrr4-Hr3hGNGN4JrNlxJxETqHqZA6K_UddsPiRf12Ws5kpZV6tHi-h9D5jh952fU6rRQfx43oFoeuZuyQyZsJBcu91Wn5g
```

Run the following command to launch gitlab in your web browser:

```
./open-gitlab.sh
```

Set the password to `password`, login with the user `root` and this password and create a new public project called `serve-model`.

Go back to the terminal in the Jupyter lab notebook and run the following command to initialize the git repo.

```
git config --global user.name "Administrator"
git config --global user.email "admin@example.com"
git init
git remote add origin http://${APPNAME}devgitlab.marathon.l4lb.thisdcos.directory/root/serve-model.git
git add .
git commit -a -m "First commit"
git push -u origin master
```

You need to replace `${APPNAME}` by the value you set in the `install.sh` script.

Run the following command to launch jenkins in your web browser:

```
./open-jenkins.sh
```

Go to `Manage Jenkins` and click on the `Correct` button on the top right corner.

Check `Pipeline: Step API` and click on `Download now and install after restart`

Check the option to restart automatically Jenkins.

When Jenkins has restarted, go to `Credentials` -> `System` -> `Global credentials (unrestricted)` and click on `Add Credentials`.

Specify `root` and `password` as the username and password and set the `ID` to `gitlab`.

Go to `Credentials` -> `System` -> `Global credentials (unrestricted)` and click on `Add Credentials`.

Specify your Docker Hub username and password and set the `ID` to `dockerhub`.

Go back to the main page and click on `Manage Jenkins` and then on `Configure System`.

Check the `Environment variables` box and add a new one called `DOCKERHUB_REPO` with the name of the Docker repository you want to use (something like `yourdockerhubusername/serve-model`).

Click on `Apply` and then on `Save`.

You can now create the Jenkins pipeline that will build the Docker image when a new commit is pushed to the gitlab repo.

Go back to the main page and click on `New Item`.

Call it `serve-model`, select `Pipeline` and click on `OK`.

Check the `Poll SCM` box and set the value to `* * * * *`.

![jenkins-poll-scm](images/jenkins-poll-scm.png)

In the `Pipeline` section, select `Pipeline script from SCM` and then `Git` as the SCM.

Specify the gitlab repo URL and the `root/******` credentials.

![jenkins-git](images/jenkins-git.png)

Click on `Apply` and then on `Save`.

Go back to the terminal in the Jupyter lab notebook.

Download the Tensorflow script in the home directory to retrain the image classifier.

```
cd ~
curl -LO https://github.com/tensorflow/hub/raw/master/examples/image_retraining/retrain.py
```

Retrain the model by indicating the path where the files have been uploaded in HDFS.

```
python retrain.py --image_dir hdfs://hdfs/user/nobody/flickr
```

When the scripts terminates, upload the model generated under `~/serve-model` and push a new commit in the git repo.

```
cd ~/serve-model
cp /tmp/output* .
git add .
git commit -a -m "With model"
git push
```

This will trigger the jenkins pipeline.

![jenkins-build](images/jenkins-build.png)

Run the following command to launch the Kubernetes Dashboard in your web browser:

```
./open-kubernetes-dashboard.sh
```

You should see the 2 pods created by jenkins.

![kubernetes-dashboard](images/kubernetes-dashboard.png)

Run the following command to launch the web application in your web browser:

```
./open-web-app.sh
```

Upload a picture of a cat or a dog and check if the model you retrain works well.

![cat](images/cat.png)
