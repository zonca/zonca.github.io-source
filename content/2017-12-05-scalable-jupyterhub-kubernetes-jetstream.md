Title: Deploy scalable Jupyterhub with Kubernetes on Jetstream
Date: 2017-12-05 18:00
Author: Andrea Zonca
Tags: jupyterhub, jetstream, gateways
Slug: scalable-jupyterhub-kubernetes-jetstream

* **Tested in June 2018 with Ubuntu 18.04 and Kubernetes 1.10**
* **Updated in February 2018 with newer version of `kubeadm-bootstrap`, Kubernetes 1.9.2**

## Introduction

The best infrastructure available to deploy Jupyterhub at scale is Kubernetes. Kubernetes provides a fault-tolerant system to deploy, manage and scale containers. The Jupyter team released a recipe to deploy Jupyterhub on top of Kubernetes, [Zero to Jupyterhub](https://zero-to-jupyterhub.readthedocs.io). In this deployment both the hub, the proxy and all Jupyter Notebooks servers for the users are running inside Docker containers managed by Kubernetes.

Kubernetes is a highly sophisticated system, for smaller deployments (30/50 users, less then 10 servers), another option is to use the Docker Swarm mode, I covered this in a [tutorial on how to deploy it on Jetstream](https://zonca.github.io/2017/10/scalable-jupyterhub-docker-swarm-mode.html).

If you are not already familiar with Kubernetes, better first read the [section about tools in Zero to Jupyterhub](https://zero-to-jupyterhub.readthedocs.io/en/latest/tools.html).

In this tutorial we will be installing Kubernetes on 2 Ubuntu instances on the XSEDE Jetstream OpenStack-based cloud, configure permanent storage with the Ceph distributed filesystem and run the "Zero to Jupyterhub" recipe to install Jupyterhub on it.

## Setup two virtual machines

First of all we need to create two Virtual Machines from the [Jetstream Atmosphere admin panel](https://use.jetstream-cloud.org)I tested this on XSEDE Jetstream Ubuntu 16.04 image (with Docker pre-installed), for testing purposes "small" instances work, then they can be scaled up for production. You can name them `master_node` and `node_1` for example.
Make sure that port 80 and 443 are open to outside connections.

Then you can SSH into the first machine with your XSEDE username with `sudo` privileges.

## Install Kubernetes

The "Zero to Jupyterhub" recipe targets an already existing Kubernetes cluster, for example on Google Cloud. However the Berkeley Data Science Education Program team, which administers one of the largest Jupyterhub deployments to date, released a set of scripts based on the `kubeadm` tool to setup Kubernetes from scratch.

This will install all the Kubernetes services and configure the `kubectl` command line tool for administering and monitoring the cluster and the `helm` package manager to install pre-packaged services.

SSH into the first server and follow the instructions at <https://github.com/data-8/kubeadm-bootstrap> to "Setup a Master Node"
this will install a more recent version of Docker.

Once the initialization of the master node is completed, you should be able to check that several containers (pods in Kubernetes) are running:

```
zonca@js-xxx-xxx:~/kubeadm-bootstrap$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                                    READY     STATUS    RESTARTS   AGE
kube-system   etcd-js-169-xx.jetstream-cloud.org                      1/1       Running   0          1m
kube-system   kube-apiserver-js-169-xx.jetstream-cloud.org            1/1       Running   0          1m
kube-system   kube-controller-manager-js-169-xx.jetstream-cloud.org   1/1       Running   0          1m
kube-system   kube-dns-6f4fd4bdf-nxxkh                                3/3       Running   0          2m
kube-system   kube-flannel-ds-rlsgb                                   1/1       Running   1          2m
kube-system   kube-proxy-ntmwx                                        1/1       Running   0          2m
kube-system   kube-scheduler-js-169-xx.jetstream-cloud.org            1/1       Running   0          2m
kube-system   tiller-deploy-69cb6984f-77nx2                           1/1       Running   0          2m
support       support-nginx-ingress-controller-k4swb                  1/1       Running   0          36s
support       support-nginx-ingress-default-backend-cb84895fb-qs9pp   1/1       Running   0          36s
```

Make also sure routing is working by accessing with your web browser the address of the Virtual Machine `js-169-xx.jetstream-cloud.org` and verify you are getting the error message `default backend - 404`.

Then SSH to the other server and set it up as a worker following the instructions in "Setup a Worker Node" at <https://github.com/data-8/kubeadm-bootstrap>,

Once the setup is complete on the worker, log back in to the master and check that the worker joined Kubernetes:

    zonca@js-169-xx:~/kubeadm-bootstrap$ sudo kubectl get nodes
    NAME                             STATUS    ROLES     AGE       VERSION
    js-168-yyy.jetstream-cloud.org   Ready     <none>    1m        v1.9.2
    js-169-xx.jetstream-cloud.org    Ready     master    2h        v1.9.2

## Setup permanent storage for Kubernetes

The cluster we just setup has no permament storage, so user data would disappear every time a container is killed.
We woud like to provide users with a permament home that would be available across all of the Kubernetes cluster, so that even if a user container spawns again on a different server, the data are available.

First we want to login again to Jetstream web interface and create 2 Volumes (for example 10 GB) and attach them one each to the master and to the first node, these will be automatically mounted on `/vol_b`, with no need of rebooting the servers.

Kubernetes has capability to provide Permanent Volumes but it needs a backend distributed file system. In this tutorial we will be using [Rook](https://rook.io/) which sets up the Ceph distributed filesystem across the nodes.

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
* `versionTag`: make sure this is the same as your `rook` version (you can find it with `sudo helm ls`)

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

This creates a Pod with Alpine Linux that requests a Persistent Volume Claim to be mounted under `/data`. The Persistent Volume Claim specified the type of storage and its size. Once the Pod is created, it asks the Persistent Volume Claim to actually request Rook to prepare a Persistent Volume that is then mounted into the Pod.

We can verify the Persistent Volumes are created and associated with the pod, check:

	sudo kubectl get pv
	sudo kubectl get pvc
	sudo kubectl get logs alpine

We can get a shell in the pod with:

	sudo kubectl exec -it alpine  -- /bin/sh

access `/data/` and make sure we can write some files.

Once you have completed testing, you can delete the pod and the Persistent Volume Claim with:

    sudo kubectl delete -f alpine-rook.yaml

The Persistent Volume will be automatically deleted by Kubernetes after a few minutes.

## Setup HTTPS with letsencrypt

We need `kube-lego` to automatically get a HTTPS certificate from Letsencrypt,
For more information see the Ingress section on the [Zero to Jupyterhub Advanced topics](http://zero-to-jupyterhub.readthedocs.io/en/latest/advanced.html).

First we need to customize the Kube Lego configuration, edit the `config_kube-lego_helm.yaml` file from the repository and set your email address, then:

    sudo helm install stable/kube-lego --namespace=support --name=lego -f config_kube-lego_helm.yaml

Then after you deploy Jupyterhub if you have some HTTPS trouble, you should check the logs of the kube-lego pod. First find the name of the pod with:

    sudo kubectl get pods -n support

Then check its logs:

    sudo kubectl logs -n support lego-kube-lego-xxxxx-xxx

## Install Jupyterhub

Read all of the documentation of "Zero to Jupyterhub", then download [`config_jupyterhub_helm.yaml` from the repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/config_jupyterhub_helm.yaml) and customize it with the URL of the master node (for Jetstream `js-xxx-xxx.jetstream-cloud.org`) and generate the random strings for security, finally run the Helm chart:

	sudo helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
	sudo helm repo update
	sudo helm install jupyterhub/jupyterhub --version=v0.6 --name=jup \
        --namespace=jup -f config_jupyterhub_helm.yaml

Once you modify the configuration you can update the deployment with:

	sudo helm upgrade jup jupyterhub/jupyterhub -f config_jupyterhub_helm.yaml

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

## Administration tips

### Add more servers to Kubernetes

We can create more Ubuntu instances (with a volume attached) and add them to Kubernetes by repeating the same setup we performed on the first worker node.
Once the node joins Kubernetes, it will be automatically used as a node for the distributed filesystem by Rook and be available to host user containers.

### Remove a server from Kubernetes

Launch first the `kubectl drain` command to move the currently active pods to other nodes:

	sudo kubectl get nodes
	sudo kubectl drain <node name>

Then suspend or delete the instance on the Jetstream admin panel.

### Configure a different authentication system

"Zero to Jupyterhub" supports out of the box authentication with:

* XSEDE credentials with CILogon
* Many Campuses credentials with CILogon
* Globus
* Google

See [the documentation](https://zero-to-jupyterhub.readthedocs.io/en/latest/extending-jupyterhub.html#authenticating-with-oauth2) and modify `config_jupyterhub_helm_v0.5.0.yaml` accordingly.

## Acknowledgements

* The Jupyter team, in particular Yuvi Panda, for providing a great software platform and a easy-to-user resrouce for deploying it and for direct support in debugging my issues
* XSEDE Extended Collaborative Support Services for supporting part of my time to work on deploying Jupyterhub on Jetstream and providing computational time on Jetstream
* Pacific Research Platform, in particular John Graham, Thomas DeFanti and Dmitry Mishin (SDSC) for access to their Kubernetes platform for testing
* XSEDE Jetstream's Jeremy Fischer for prompt answers to my questions on Jetstream
