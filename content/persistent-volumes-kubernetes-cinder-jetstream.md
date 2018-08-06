Title: Persistent volumes for Kubernetes on Jetstream with Cinder
Date: 2018-06-23 18:00
Author: Andrea Zonca
Tags: kubernetes, jetstream, jupyterhub
Slug: persistent-volumes-kubernetes-cinder-jetstream

In my original [tutorial about deploying Kubernetes and Jupyterhub on Jetstream](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html) I recommended to use Rook for persistent storage.
Rook is pretty easy to deploy but I noticed that when testing with few instances it sometimes
reports errors, my understanding is that Ceph is expected to run at large scale and doesn't work
very well in small virtual machines with limited memory and limited disk space.
The issue probably would disappear for a production deployment, however it makes it hard to test
a deployment because sometimes the `rook` containers go out of memory and keep restarting.

Moreover, persistent volumes are already a key feature of the Jetstream Openstack deployment,
so it is easier to rely on the existing infrastructure to also provide persistent volumes for
Kubernetes. The Openstack project providing volumes, for example the volumes we can create and
attach to instances in the Atmosphere web interface, is provided by Cinder.

In this tutorial we are going to configure the Kubernetes service `standalone-cinder` to dinamically
provide Openstack volumes whenever a Kubernetes pod requests it. This will be both for the JupyterHub
database and for all the users data.

## Requirements

You should already have a Kubernetes cluster running on Jetstream, see the first section of my original [tutorial about deploying Kubernetes and Jupyterhub on Jetstream](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html).

If you have already deployed JupyterHub with Zero-to-Jupyterhub, you can leave it running and update it with the new
configuration after you completed the setup below.

## Git repository

The necessary configuration files are inside the same repository of the original deployment, you
should already have it cloned in the home folder of your user on the Jetstream master node of the Kubernetes deployment:

    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/

## Bash aliases

To make typing Kubernetes commands quicker, I created some shortcuts, see my [`.bash_aliases`](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/.bash_aliases) file, you can symlink it into your home folder.

The most convenient is `kn`, it allows you to set first the namespace, then all next commands will use it:

```
> N=support
> kn get pods
NAME                                                    READY     STATUS    RESTARTS   AGE
lego-kube-lego-f89fbb699-ppmzd                          1/1       Running   0          19m
support-nginx-ingress-controller-qn82m                  1/1       Running   1          7d
support-nginx-ingress-default-backend-cb84895fb-wh62v   1/1       Running   0          7d
> N=jup
> kn get pods
NAME                              READY     STATUS              RESTARTS   AGE
hub-5848c86775-kz7kn              0/1       ContainerCreating   0          18m
pre-pull-jup-1-1529746578-dbkxm   1/1       Running             0          19m
proxy-6b57b95db5-sgnjz            2/2       Running             0          18m

git clone --depth 1 git@github.com:kubernetes-incubator/external-storage.git

    cd external-storage/openstack/standalone-cinder/manifests

Create the RBAC roles

    sudo kubectl create -f rbac

```
clusterrole.rbac.authorization.k8s.io "cinder-standalone-provisioner" created
clusterrolebinding.rbac.authorization.k8s.io "cinder-standalone-provisioner" created
role.rbac.authorization.k8s.io "cinder-standalone-provisioner" created
rolebinding.rbac.authorization.k8s.io "cinder-standalone-provisioner" created
serviceaccount "cinder-standalone-provisioner" created
```

## (Optional) Test credentials

source openrc.sh

sudo sudo apt install python3-openstackclient

openstack volume create --size 1  testvol

```
+---------------------+------------------------------------------------------------------+
| Field               | Value                                                            |
+---------------------+------------------------------------------------------------------+
| attachments         | []                                                               |
| availability_zone   | nova                                                             |
| bootable            | false                                                            |
| consistencygroup_id | None                                                             |
| created_at          | 2018-06-15T11:47:43.162759                                       |
| description         | None                                                             |
| encrypted           | False                                                            |
| id                  | 6ae83e11-7275-429b-8214-82d4937afdda                             |
| multiattach         | False                                                            |
| name                | testvol                                                          |
| properties          |                                                                  |
| replication_status  | None                                                             |
| size                | 1                                                                |
| snapshot_id         | None                                                             |
| source_volid        | None                                                             |
| status              | creating                                                         |
| type                | default                                                          |
| updated_at          | None                                                             |
| user_id             | afdkajfdlksajfldsasdfsdfadsafdsafdsafdsafdafdafdsafdsafdafdafdda |
+---------------------+------------------------------------------------------------------+
```


Edit `deployment.yaml`:



  - `OS_AUTH_URL`
  - `OS_PROJECT_ID`
  - `OS_PROJECT_NAME`
  - `OS_USER_DOMAIN_NAME`
  - `OS_USER_DOMAIN_ID`
  - `OS_USERNAME`
  - `OS_PASSWORD`
  - `OS_REGION_NAME`

set from openrc.sh

Add another 2 lines for `OS_USER_DOMAIN_ID` which is not available

sudo kubectl create -f deployment.yaml


wget https://iu.jetstream-cloud.org:35357/v3
wget https://iu.jetstream-cloud.org:5000/v3


    sudo helm install jupyterhub/jupyterhub --version=v0.6 --name=jup     --namespace=jup -f config_jupyterhub_helm.yaml -f secrets.yaml -f storage_cinder/config_jupyterhub_cinder_storage.yaml
