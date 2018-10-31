Title: Explore a Kubernetes deployment on Jetstream with Kubespray 2/3
Date: 2018-09-23 23:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream
Slug: kubernetes-jetstream-kubespray-explore

This is the second part of the tutorial on deploying Kubernetes with `kubespray` and JupyterHub
on Jetstream.

In the [first part, we installed Kubernetes on Jetstream with `kubespray`](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html).

It is optional, its main purpose is to familiarize with the Kubernetes deployment on Jetstream
and how the different components play together before installing JupyterHub.
If you are already familiar with Kubernetes you can skip to [next part where we will be installing
Jupyterhub using the zerotojupyterhub helm recipe](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html).

All the files for the examples below are available on Github,
first SSH to the master node (or do this locally if you setup `kubectl` locally):

```
git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream
cd jupyterhub-deploy-kubernetes-jetstream
```

## Test persistent storage with cinder

The most important feature that brought me to choose `kubespray` as method for installing Kubernetes
is that it automatically sets up persistent storage exploiting Jetstream Volumes.
The Jetstream team already does a great job in providing a persistent storage solution with adequate
redundancy via the Cinder project, part of OpenStack.

`kubespray` sets up a Kubernetes provisioner so that when a container requests persistent storage,
it talks to the Openstack API and have a dedicated volume (the same type you can create with the
Jetstream Horizon Web interfaces) automatically created and exposed to Kubernetes.

This is achieved through a storageclass:

```
kubectl get storageclass
NAME                 PROVISIONER            AGE
standard (default)   kubernetes.io/cinder   1h
```

See the file `alpine-persistent-volume.yaml` in the repository on how we can request a Cinder volume
to be created and attached to a pod.

```
kubectl create -f alpine-persistent-volume.yaml
```

We can test it by getting a terminal inside the container (`alpine` has no `bash`):

```
kubectl exec -it alpine -- /bin/sh
```

look into `df -h`, check that there is a 5GB mounted filesystem which is persistent.

Also, back to the machine with `openstack` access, see how an Openstack volume was dynamically created and attached to the running instance:

    openstack volume list


```
openstack volume list
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
| ID                                   | Name                                                        | Status | Size | Attached to                                      |
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
| 508f1ee7-9654-4c84-b1fc-76dd8751cd6e | kubernetes-dynamic-pvc-e83ec4d6-bb9f-11e8-8344-fa163eb22e63 | in-use |    5 | Attached to kubespray-k8s-node-nf-1 on /dev/sdb  |
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
```

## Test ReplicaSets, Services and Ingress

In this section we will explore how to build redundancy and scale in a service with a
simple example included in the book [Kubernetes in Action](https://github.com/luksa/kubernetes-in-action/tree/master/Chapter02/kubia),
which by the way I highly recommend to get started with Kubernetes.

First let's deploy a service in our Kubernetes cluster,
this service just answers to HTTP requests on port 8080 with the message "You've hit kubia-manual":

    cd kubia_test_ingress
    kubectl create -f kubia-manual.yaml

We can test it by checking at which IP Kubernetes created the pod:

    kubectl get pods -o wide

and assign it to the `KUBIA_MANUAL_IP` variable, then on one of the nodes:

    $ curl $KUBIA_MANUAL_IP:8080
    You've hit kubia-manual

Finally close it:

    kubectl delete -f kubia-manual.yaml

### Load balancing with ReplicaSets and Services

Now we want to scale this service up and provide a set of 3 pods instead of just 1:

    kubectl create -f kubia-replicaset.yaml

Now we could access those services on 3 different IP addresses, but we would like to have
a single entry point and automatic load balancing across those instances, so we create
a Kubernetes "Service" resource:

    kubectl create -f kubia-service.yaml

And test it:

```
$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   22h
kubia        ClusterIP   10.233.28.205   <none>        80/TCP    45m
```

    curl $KUBIA_SERVICE_IP

This is on port 80 so we don't need `:8080` in the URL.
Run many times and check different kubia services answer.

### Publish service externally with ingress

Try to open browser and access the hostname of your master node at:

    http://js-XXX-YYY.jetstream-cloud.org

Where XXX-YYY are the last 2 groups of digits of the floating IP of the master instance,
i.e. AAA.BBB.XXX.YYY, each of them could also be 1 or 2 digits instead of 3.

The connection should be respond with 404.

Now:

    kubectl create -f kubia-ingress.yaml
    kubectl get ingress

Try again in the browser.
