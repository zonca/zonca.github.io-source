Title: Deploy Kubernetes and JupyterHub on Jetstream with Magnum
Date: 2019-06-14 0:00
Author: Andrea Zonca
Tags: kubernetes, openstack, jetstream, jupyterhub
Slug: kubernetes-jupyterhub-jetstream-magnum

This tutorial deploys Kubernetes on Jetstream with Magnum and then
JupyterHub on top of that using [zero-to-jupyterhub](https://zero-to-jupyterhub.readthedocs.io/).

In my [previous tutorials](https://zonca.github.io/2019/02/kubernetes-jupyterhub-jetstream-kubespray.html) I deployed Kubernetes using Kubespray. The main driver to using Magnum is that there is support for autoscaling, i.e. create and destroy Openstack instances based on the load on JupyterHub. I haven't tested that yet, though, that will come in a following tutorial.

Magnum is a technology built into Openstack to deploy Container Orchestration engines based on templates. The main difference with kubespray is that is way less configurable, the user does not have access to modify those templates but has just a number of parameters to set. Instead Kubespray is based on `ansible` and the user has full control of how the system is setup, it also supports having more High Availability features like multiple master nodes.
On the other hand, the `ansible` recipe takes a very long time to run, ~30 min, while Magnum creates a cluster in about 10 minutes.

## Setup the Openstack client

First you need to be able to use the Jetstream API with the `openstack` command line tool.

Install it on Ubuntu via the `python3-openstackclient` package or:

    pip install python-openstackclient

Then follow the "Request API Access" section in my [initial tutorial](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html). After this you should be able to run successfully openstack commands like:

    openstack flavor list

## Create the cluster with Magnum

As usual, first checkout the repository with all the configuration files on the machine you will use the Jetstream API from, typically your laptop.

    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream
    cd jupyterhub-deploy-kubernetes-jetstream
    cd kubernetes_magnum

Then install the OpenStack client, please use these exact versions, also please run at Indiana, which currently has the Rocky release of Openstack, the TACC deployment has an older release of Openstack.

    pip install python-openstackclient==3.16 python-magnumclient==2.10

Load your API credentials from `openrc.sh`, check [documentation of the Jetstream wiki for details](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/39682064/Setting+up+openrc.sh).

Now we are ready to use Magnum to first create a cluster template and then the actual cluster:

    bash create_template.sh
    bash create_cluster.sh

I have setup a test cluster with only 1 master node and 1 normal node but you can modify that later.

Check the status of your cluster, after about 10 minutes, it should be in state `CREATE_COMPLETE`:

    openstack coe cluster show k8s

### Configure kubectl locally

Install the `kubectl` client locally, first check the version of the master node:

    openstack server list # find the floating public IP of the master node (starts with 149_
    IP=149.xxx.xxx.xxx
    ssh fedora@$IP
    kubectl version

Now install the same version following the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Now configure `kubectl` on your laptop to connect to the Kubernetes cluster created with Magnum:

    mkdir kubectl_secret
    cd kubectl_secret
    openstack coe cluster config k8s

This downloads a configuration file and the required certificates.

and returns  `export KUBECONFIG=/absolute/path/to/config`

execute that and then:

    kubectl get nodes

## Configure storage

Magnum configures a provider that knows how to create Kubernetes volumes using Openstack Cinder,
but does not configure a `storageclass`, we can do that with:

    kubectl create -f storageclass.yaml

We can test this creating a Persistent Volume Claim:

    kubectl create -f persistent_volume_claim.yaml

    kubectl describe pv

```
Name:            pvc-e8b93455-898b-11e9-a37c-fa163efb4609
Labels:          failure-domain.beta.kubernetes.io/zone=nova
Annotations:     kubernetes.io/createdby: cinder-dynamic-provisioner
                 pv.kubernetes.io/bound-by-controller: yes
                 pv.kubernetes.io/provisioned-by: kubernetes.io/cinder
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    standard
Status:          Bound
Claim:           default/pvc-test
Reclaim Policy:  Delete
Access Modes:    RWO
Capacity:        5Gi
Node Affinity:   <none>
Message:         
Source:
    Type:       Cinder (a Persistent Disk resource in OpenStack)
    VolumeID:   2795724b-ef11-4053-9922-d854107c731f
    FSType:     
    ReadOnly:   false
    SecretRef:  nil
Events:         <none>
```

We can also test creating an actual pod with a persistent volume and check
that the volume is successfully mounted and the pod started:

    kubectl create -f ../alpine-persistent-volume.yaml
    kubectl describe pod alpine

### Note about availability zones

By default Openstack servers and Openstack volumes are created in different availability zones. This created an issue with the default Magnum templates because we need to modify the Kubernetes scheduler policy to allow this. Kubespray does this by default, so I created a [fix to be applied to the Jetstream Magnum templates](https://github.com/zonca/magnum/pull/1), this needs to be re-applied after every Openstack upgrade.

## Install Helm

The Kubernetes deployment from Magnum is not as complete as the one out of Kubespray, we need
to setup `helm` and the NGINX ingress ourselves. We would also need to setup a system to automatically
deploy HTTPS certificates, I'll add this later on.

First [install the Helm client on your laptop](https://helm.sh/docs/using_helm/#installing-helm), make
sure you have configured `kubectl` correctly.

Then we need to create a service account to give enough privilege to Helm to reconfigure the cluster:

    kubectl create -f tiller_service_account.yaml

Then we can create the `tiller` pod inside Kubernetes:

    helm init --service-account tiller --wait --history-max 200

```
kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   coredns-78df4bf8ff-f2xvs                   1/1     Running   0          2d
kube-system   coredns-78df4bf8ff-pnj7g                   1/1     Running   0          2d
kube-system   heapster-74f98f6489-xsw52                  1/1     Running   0          2d
kube-system   kube-dns-autoscaler-986c49747-2m64g        1/1     Running   0          2d
kube-system   kubernetes-dashboard-54cb7b5997-c2vwx      1/1     Running   0          2d
kube-system   openstack-cloud-controller-manager-tf5mc   1/1     Running   3          2d
kube-system   tiller-deploy-6b5cd64488-4fkff             1/1     Running   0          20s
```

And check that all the versions agree:

```
helm version
Client: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.11.0", GitCommit:"2e55dbe1fdb5fdb96b75ff144a339489417b146b", GitTreeState:"clean"}
```

## Setup NGINX ingress

We need to have the NGINX web server to act as front-end to the services running inside the Kubernetes cluster.

### Open HTTP and HTTPS ports

First we need to open the HTTP and HTTPS ports on the master node, you can either connect to the Horizon interface,
create new rule named `http_https`, then add 2 rules, in the Rule drop down choose HTTP and HTTPS; or from the command line:

    openstack security group create http_https
    openstack security group rule create --ingress --protocol tcp --dst-port 80 http_https 
    openstack security group rule create --ingress --protocol tcp --dst-port 443 http_https 

Then you can find the name of the master node in `openstack server list` then add this security group to that instance:

    openstack server add security group  k8s-xxxxxxxxxxxx-master-0 http_https

### Install NGINX ingress with Helm

    bash install_nginx_ingress.sh

Note, the documentation says we should add this annotation to ingress with `kubectl edit ingress -n jhub`, but I found out it is not necessary:

    metadata:
      annotations:
        kubernetes.io/ingress.class: nginx

If this is correctly working, you should be able to run `curl localhost` from the master node and get a `Default backend: 404` message.

## Install JupyterHub

Finally, we can go back to the root of the repository and install JupyterHub, first create the secrets file:

    bash create_secrets.sh

Then edit `secrets.yaml` and modify the hostname under `hosts` to display the hostname of your master Jetstream instance, i.e. if your instance public floating IP is `aaa.bbb.xxx.yyy`, the hostname should be `js-xxx-yyy.jetstream-cloud.org` (without `http://`).

Finally:

    bash install_jhub.sh

Connect with your browser to `js-xxx-yyy.jetstream-cloud.org` to check if it works.

## Issues and feedback

Please [open an issue on the repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/) to report any issue or give feedback. Also you find out there there what I am working on next.

## Acknowledgments

Many thanks to Jeremy Fischer and Mike Lowe for solving all my tickets, this required a lot of work on their end to make it working.
