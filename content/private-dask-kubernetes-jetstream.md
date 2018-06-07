Title: Setup private dask clusters in Kubernetes alongside JupyterHub on Jetstream
Date: 2018-06-07 18:00
Author: Andrea Zonca
Tags: jupyter, jetstream, dask
Slug: private-dask-kubernetes-jetstream

In this post we will leverage software made available by the [Pangeo community](https://pangeo-data.github.io) to allow each user of a [Jupyterhub instance deployed on Jetstream on top of Kubernetes](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html) to launch a set of [`dask`](https://dask.pydata.org) workers as containers running inside Kubernetes itself and use them for distributed computing.

Pangeo also maintains a deployment of this environment on Google Cloud freely accessible at [pangeo.pydata.org](https://pangeo.pydata.org).

**Security considerations**: This deployment grants each user administrative access to the Kubernetes API, so each user could use this privilege to terminate other users' pods or dask workers. Therefore it is suitable only for a community of trusted users. There is [discussion about leveraging namespaces to limit this](https://github.com/pangeo-data/pangeo/issues/135#issuecomment-384320753) but it hasn't been implemented yet.

## Deploy Kubernetes

We need to first create Jetstream instances and deploy Kubernetes on them. We can follow the first part of the tutorial at [https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html).
I also tested with Ubuntu 18.04 instead of Ubuntu 16.04 and edited the `install-kubeadm.bash` accordingly, I also removed version specifications in order to pickup the latest Kubernetes version, currently 1.10. See [my install-kubeadm-18.04.bash](https://gist.github.com/zonca/5365fd2245462dedaf2297e0417c4662).
Notice that for the `http://apt.kubernetes.io/` don't have yet Ubuntu 18.04 packages, so I left `xenial`, this should be updated in the future.

In order to simplify the setup we will just be using ephemeral storage, later we can update the deployment using either Rook following the [steps in my original tutorial](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html) or a NFS share (I'll write a tutorial soon about that).

## Deploy Pangeo

Deployment is just a single step because Pangeo published a Helm recipe that depends on the Zero-to-JupyterHub recipe and deploys both in a single step, therefore we *should not have deployed JupyterHub beforehand*.

First we need to create a `yaml` configuration file for the package.
Checkout the Github repository with all the configuration files on the master node of Kubernetes:

    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream

in the `pangeo_helm` folder, there is already a draft of the configuration file.

We need to:

* run `openssl` as instructed inside the file and paste the output tokens to the specified location
* edit the hostname in the `ingress` section to the hostname of the Jetstream master node
* customize the memory and CPU requirements, currently they are very low so that this can be tested also in a single small instance

We can then deploy with:

    sudo helm install pangeo/pangeo -n pangeo --namespace pangeo -f config_pangeo_no_storage.yaml --version=v0.1.1-95ab292

You can optionally check if there are newer versions of the chart at [https://pangeo-data.github.io/helm-chart/](https://pangeo-data.github.io/helm-chart/).

Then check that the pods start checking their status with:

    sudo kubectl -n pangeo get pods

If any is stuck in Pending, check with:

    sudo kubectl -n pangeo describe <pod-name>

Once the `hub` pod is running, you should be able to connect with your browser to `js-xxx-xxx.Jetstream-cloud.org`, by default it runs with a dummy authenticator, just digit a username and leave the password empty to login.

## Launch a dask cluster

Once you get the Jupyter Notebook instance, you should see a file named `worker-template.yaml` in your home folder, this is a template for the configuration and the allocated resources for the pod of each `dask` worker.
The default workers for Pangeo are beefy, for testing we can reduce their requirements, see for example my [worker-template.yaml](https://gist.github.com/zonca/21ef3125eee7af5c2548e505d47dc200) that works on a small Jetstream VM.

Then inside `examples/` we have several example notebooks that show how to use `dask` for distributed computing.
`dask-array.ipynb` shows basic functionality for distributed multi-dimensional arrays.

The most important piece of code is the creation of dask workers:

```
from dask_kubernetes import KubeCluster
cluster = KubeCluster(n_workers=2)
cluster
```

If we execute this cell `dask_kubernetes` contacts the Kubernetes API using the [serviceaccount `daskkubernetes`](https://github.com/pangeo-data/helm-chart/blob/master/pangeo/templates/dask-kubernetes-rbac.yaml) mounted on the pods by the Helm chart and requests new pods to be launched.
In fact we can check on the terminal again with:

    sudo kubectl -n pangeo get pods

that new pods should be about to run.
It also provides buttons to change the number of running workers, either manually or adaptively based on the required resources.

This also runs the `dask` scheduler on the pod that is running the Jupyter Notebook and we can connect to it with:

    from dask.distributed import Client
    client = Client(cluster)
    client

From now on all `dask` commands will automatically execute commands on the `dask` cluster.

## Customize the JupyterHub deployment

We can then customize the JupyterHub deployment for example to add authentication or permanent storage.
Notice that all configuration options inside the `config_pangeo_no_storage.yaml` are inside the `jupyterhub:` tag, this is due to the fact that `jupyterhub` is another Helm package which we are configuring through the `pangeo` Helm package.
Therefore make sure that any configuration option found in my previous tutorials or on the [Zero-to-Jupyterhub](https://zero-to-jupyterhub.readthedocs.io/en/latest/) documentation needs to be indented accordingly.

Then we can either run:

    sudo helm delete --purge pangeo

and then install it from scratch again or just update the running cluster with:

    sudo helm upgrade pangeo -f config_pangeo_no_storage.yaml
