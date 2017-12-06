Title: Deploy scalable Jupyterhub with Kubernetes on Jetstream
Date: 2017-12-05 18:00
Author: Andrea Zonca
Tags: jupyterhub, jetstream, gateways
Slug: scalable-jupyterhub-kubernetes-jetstream

## Introduction

The best infrastructure available to deploy Jupyterhub at scale is Kubernetes. It provides a fault-tolerant system to deploy, manage and scale containers. The Jupyter team released a recipe to deploy Jupyterhub on top of Kubernetes, [Zero to Jupyterhub](https://zero-to-jupyterhub.readthedocs.io).

Kubernetes is a highly sophisticated system, for smaller deployments (30/50 users, less then 10 servers), another option is to use the Docker Swarm mode, I covered this in a [tutorial on how to deploy it on Jetstream](https://zonca.github.io/2017/10/scalable-jupyterhub-docker-swarm-mode.html).

If you are not already familiar with Kubernetes, better first read the [section about tools in Zero to Jupyterhub](https://zero-to-jupyterhub.readthedocs.io/en/latest/tools.html).

## Setup two virtual machines

First of all we need to create two Virtual Machines from the [Jetstream Atmosphere admin panel](https://use.jetstream-cloud.org)I tested this on XSEDE Jetstream Ubuntu 16.04 image (with Docker pre-installed), for testing purposes "small" instances work, then they can be scaled up for production. You can name them `master_node` and `node_1` for example.

Then you can SSH into the first machine with your XSEDE username with `sudo` privileges.

## Install Kubernetes

The "Zero to Jupyterhub" recipe targets an already existing Kubernetes cluster, for example on Google Cloud. However they also released a set of scripts based on the `kubeadm` tool to setup Kubernetes on other servers.

This will install all the Kubernetes services and configure the `kubectl` command line tool for administering and monitoring the cluster and the `helm` package manager to install pre-packaged services.

SSH into the first server and follow the instructions at <https://github.com/data-8/kubeadm-bootstrap> to "Setup a Master Node"
this will install a more recent version of Docker. In `config.bash`, as Master IP set the ip of the `ens3` device, for example from:

    ip address show dev ens3

this is the internal IP of the server, which is good for internal networking between the master and the other nodes, no need to use the public IP.

In case the script gives the error `Error: could not find a ready tiller pod`, it is due to the fact that 1 minute sleep in the script is not enough to start the tiller pod required by Helm. Just execute it again:

    sudo helm install --name=support --namespace=support support/

Then SSH to the other server and set it up as a worker following the instructions in "Setup a Worker Node" at <https://github.com/data-8/kubeadm-bootstrap>,

Once the setup is complete on the worker, log back in to the master and check that the worker joined Kubernetes:

	zonca@js-xxx-xxx:~/kubeadm-bootstrap$ sudo kubectl get nodes
	NAME                             STATUS    ROLES     AGE       VERSION
	js-169-xxx.jetstream-cloud.org   Ready     master    17m       v1.8.4
	js-169-jjj.jetstream-cloud.org   Ready     <none>    23s       v1.8.4

## Setup permanent storage for Kubernetes

The cluster we just setup has no permament storage, so user data would disappear every time a container is killed.
We woud like to provide users with a permament home that would be available across all of the Kubernetes cluster, so that even if a user container spawns again on a different servers, the data are available.

First we want to login again to Jetstream web interface and create 2 Volumes (for example 10 GB) and attach them one each to the master and to the first node, this will be automatically mounted on `/vol_b`, with no need of rebooting the servers.

Kubernetes has capability to provide Permanent Volumes but it needs a backend distributed file system. In this tutorial we will be using [Rook](https://rook.io/).

We can first use Helm to install the Rook services (I ran my tests with `v0.6.1`):

	sudo helm repo add rook-alpha https://charts.rook.io/alpha
	sudo helm install rook-alpha/rook

Then check that the pods have started:

	zonca@js-xxx-xxx:~/kubeadm-bootstrap$ sudo kubectl get pods
	NAME                            READY     STATUS    RESTARTS   AGE
	rook-agent-2v86r                1/1       Running   0          1h
	rook-agent-7dfl9                1/1       Running   0          1h
	rook-operator-88fb8f6f5-tss5t   1/1       Running   0          1h

Once the pods have started we can actually configure the storage, copy this [`rook-cluster.yaml` file](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/storage_rook/rook-cluster.yaml) to the master node. Better clone all of the repository as we will be using other files later.

The most important bits are:

* `dataDirHostPath`: this is a folder to save the Rook configuration, we can set it to `/var/lib/rook`
* `storage: directories`: this is were data is stored, we can set this to `/vol_b` which is the default mount point of Volumes on Jetstream. This way we can more easily back those up or increase their size.

Then run it with:

	sudo kubectl create -f rook-cluster.yaml

And wait for the services to launch:

	zonca@js-xxx-xxx:~/kubeadm-bootstrap$ sudo kubectl -n rook get pods
	NAME                              READY     STATUS    RESTARTS   AGE
	rook-api-68b87d48d5-xmkpv         1/1       Running   0          6m
	rook-ceph-mgr0-5ddd685b65-kw9bz   1/1       Running   0          6m
	rook-ceph-mgr1-5fcf599447-j7bpn   1/1       Running   0          6m
	rook-ceph-mon0-g7xsk              1/1       Running   0          7m
	rook-ceph-mon1-zbfqt              1/1       Running   0          7m
	rook-ceph-mon2-c6rzf              1/1       Running   0          6m
	rook-ceph-osd-82lj5               1/1       Running   0          6m
	rook-ceph-osd-cpln8               1/1       Running   0          6m

This step launches the distributed file system Ceph on all nodes.

Finally we can create a new StorageClass which provides block storage for the pods to store data persistently, get [`rook-storageclass.yaml` from the same repository we used before](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/storage_rook/rook-storageclass.yaml) and execute with:

	sudo kubectl create -f rook-storageclass.yaml

You should now have the rook storageclass available:

	sudo kubectl get storageclass
	NAME         PROVISIONER
	rook-block   rook.io/block

### (Optional) Test Rook Persistent Storage

Optionally, we can deploy a simple pod to verify that the storage system is working properly.

You can copy [`alpine-rook.yaml` from Github](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/storage_rook/alpine-rook.yaml)
and launch it with:

	sudo kubectl create -f alpine-rook.yaml

It is a very small pod with Alpine Linux that creates a 2 GB volume from Rook and mounts it on `/data`.

We can verify the Persistent Volumes are created and associated with the pod, check:

	sudo kubectl get pv
	sudo kubectl get pvc
	sudo kubectl get logs alpine

We can get a shell in the pod with:

	sudo kubectl exec -it alpine  -- /bin/sh

access `/data/` and make sure we can write some files.

## Install Jupyterhub

Read all of the documentation of "Zero to Jupyterhub", then download [`config_jupyterhub_helm_v0.5.0.yaml` from the repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/config_jupyterhub_helm_v0.5.0.yaml) and customize it with the URL of the master node (for Jetstream `js-xxx-xxx.jetstream-cloud.org`) and generate the random strings for security, finally run the Helm chart:

	sudo helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
	sudo helm repo update
	sudo helm install jupyterhub/jupyterhub \
		--version=v0.5 \
		--name=jup \
		--namespace=jup \
		-f config_jupyterhub_helm_v0.5.0.yaml

### Test Jupyterhub

Connect to the public URL of your master node instance at: <https://js-xxx-xxx.jetstream-cloud.org>

Try to login with your XSEDE username and password and check if Jupyterhub works properly.

If something is wrong, check:

	sudo kubectl --namespace=jup get pods

Get the name of the `hub` pod and check the logs:

	sudo kubectl --namespace=jup logs hub-xxxx-xxxxxxx

Check that Rook is working properly:

	sudo kubectl --namespace=jup get pv
	sudo kubectl --namespace=jup get pvc
	sudo kubectl --namespace=jup describe pvc claim-YOURXSEDEUSERNAME
