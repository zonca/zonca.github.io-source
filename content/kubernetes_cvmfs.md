Title: Deploy CVMFS on Kubernetes
Date: 2020-02-26 13:00
Author: Andrea Zonca
Tags: kubernetes, jetstream, jupyterhub
Slug: cvmfs-kubernetes

[CVMFS](https://cvmfs.readthedocs.io/) is a software distribution service, it is used by High Energy Physics experiments at CERN
to synchronize software environments across the whole collaborations.

In the context of a Kubernetes + JupyterHub deployment on Jetstream, for example [deployed using Magnum following my tutorial](http://zonca.github.io/2019/06/kubernetes-jupyterhub-jetstream-magnum.html), it is useful to use CVMFS to make the software tools of a collaboration to all the users connected to JupyterHub, so that we can keep the base Docker image simpler and smaller.

## Alternatives

A already existing solution is [the CVMFS CSI driver](https://github.com/cernops/cvmfs-csi), however it doesn't have much documentation, so I haven't tested it. It would be useful for larger deployments, but we are designing for a 5 (possibly up to 10) nodes Kubernetes cluster.

## Architecture

We have a pod running in Kubernetes (running as a privileged Docker container) which runs the CVMFS client and caches locally
(on a dedicated Openstack volume) some pre-defined CVMFS repositories (at the moment we do not support automounting).

Currently we are using the `DIRECT` connection for the CVMFS client, due to having just a single client which accesses
a small amount of data. Using a proxy is required instead for heavier usage, and it could also be deployed inside Kubernetes.

The same pod also runs a NFS server and exposes it internally into the Kubernetes cluster, over the local Jetstream network,
to any other pod which can use a NFS volume and mount it to the `/cvmfs` folder inside the container.
We also activate the CVMFS configuration options for NFS support, following the [documentation](https://cvmfs.readthedocs.io/en/stable/cpt-configure.html#nfs-server-mode).

## Deployment

The repositories used in this deployment are:

* [Github repository for the Docker image of the CVMFS client](https://github.com/zonca/docker-cvmfs-client)
* Docker Hub repositories where the 2 containers are built: [`cvmfs-client`](https://hub.docker.com/r/zonca/cvmfs-client) and [`cvmfs-client-nfs`](https://hub.docker.com/r/zonca/cvmfs-client-nfs)
* The [`jupyterhub-deploy-kubernetes-jetstream`](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/tree/master/cvmfs) Github repositories with the Kubernetes configuration files

First we need to checkout the `jupyterhub-deploy-kubernetes-jetstream` repository:

    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream.git
    cd jupyterhub-deploy-kubernetes-jetstream/cvmfs

Then configure the CVMFS pod with the required repositories, see the `CVMFS_REPOSITORIES` variable in [`pod_cvmfs_nfs.yaml`](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/cvmfs/pod_cvmfs_nfs.yaml).

Then deploy the pod with:

    kubectl create -f pod_cvmfs_nfs.yaml

This creates 2 Openstack volumes, a 20 GB volume for the CVMFS cache, and a 1 GB volume which is just necessary as the `/cvmfs` root folder of the NFS server.
It also creates the `nfs-service` Service, with a fixed IP, so that we can use it in the pod using this.

Finally we can create a pod using mounting the folder via NFS:

    kubectl create -f test_nfs_mount.yaml

Then get a terminal in the pod with:

    bash ../terminal_pod.sh test-nfs-mount

This creates a volume which mounts the `/cvmfs` folder shared with NFS, this automatically also shares also all the subfolders.

Finally we can check the content of the `/cvmfs` folder.
