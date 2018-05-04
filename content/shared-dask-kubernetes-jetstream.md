Title: Launch a shared dask cluster in Kubernetes alongside JupyterHub on Jetstream
Date: 2018-05-04 18:00
Author: Andrea Zonca
Tags: jupyter, jetstream, dask
Slug: shared-dask-kubernetes-jetstream

Let's assume we have already a Kubernetes deployment and have installed JupyterHub, see for example my [previous tutorial on Jetstream](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html).
Now that users can login and access a Jupyter Notebook, we would also like to provide them more computing power for their interactive data exploration. The easiest way is through [`dask`](https://dask.pydata.org), we can launch a scheduler and any number of workers as containers inside Kubernetes so that users can leverage the computing power of many Jetstream instances at once.

There are 2 main strategies, we can give each user their own dask cluster with exclusive access and this would be more performant but cause quick spike of usage of the Kubernetes cluster, or just launch a shared cluster and give all users access to that.

In this tutorial we cover the second scenario, we'll cover the first scenario in a following tutorial.

We will deploy first Jupyterhub through the Zero-to-JupyterHub guide, then launch via Helm a fixed size dask clusters and show how users can connect, submit distributed Python jobs and monitor their execution on the dashboard.

The configuration files mentioned in the tutorial are available in the Github repository [zonca/jupyterhub-deploy-kubernetes-jetstream](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream).

## Deploy JupyterHub

First we start from Jupyterhub on Jetstream with Kubernetes at <https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html>

Optionally, for testing purposes, we can simplify the deployment by skipping permanent storage, if this is an option, see the relevant section below.

We want to install Jupyterhub in the `pangeo` namespace with the name `jupyter`, replace the `helm install` line in the tutorial with:

```
sudo helm install --name jupyter jupyterhub/jupyterhub -f config_jupyterhub_pangeo_helm.yaml --namespace pangeo
```

The `pangeo` configuration file is using a different single user image which has the right version of `dask` for this tutorial.

## (Optional) Simplify deployment using ephemeral storage

Instead of installing and configuring rook, we can temporarily disable permanent storage to make the setup quicker and easier to maintain.

In the JupyterHub configuration `yaml` set:

```
hub:
   db:
     type: sqlite-memory

singleuser:
   storage:
      type: none
```

Now every time a user container is killed and restarted, all data are gone, this is good enough for testing purposes.

## Configure Github authentication

Follow the instructions on the Zero-to-Jupyterhub documentation, at the end you should have in the YAML:

```
auth:
  type: github
  admin:
    access: true
    users: [zonca, otherusername]
  github:
    clientId: "xxxxxxxxxxxxxxxxxxxx"
    clientSecret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    callbackUrl: "https://js-xxx-xxx.jetstream-cloud.org/hub/oauth_callback"
```

## Test Jupyterhub

Connect to the master node with your browser at: `https://js-xxx-xxx.jetstream-cloud.org`
Login with your Github credentials, you should get a Jupyter Notebook.

You can also check that your pod is running:

```
sudo kubectl get pods -n pangeo
NAME                                  READY     STATUS    RESTARTS   AGE
jupyter-zonca                         1/1       Running   0          2m
......other pods
```

## Install Dask

We want to deploy a single dask cluster that all the users can submit jobs to:

```
sudo helm repo add dask https://dask.github.io/helm-chart/
sudo helm repo update
```

Customize the `dask_shared/dask_config.yaml` file available in the repository,
for testing purposes I set just 1 GB RAM and 1 CPU limits on each of 3 workers.
We can change `replicas` of the workers to add more.

    sudo helm install dask/dask --name=dask --namespace=pangeo -f dask_config.yaml

Then check that the `dask` instances are running:

```
$ sudo kubectl get pods --namespace pangeo
NAME                              READY     STATUS    RESTARTS   AGE
dask-jupyter-647bdc8c6d-mqhr4     1/1       Running   0          22m
dask-scheduler-5d98cbf54c-4rtdr   1/1       Running   0          22m
dask-worker-6457975f74-dqhsh      1/1       Running   0          22m
dask-worker-6457975f74-lpvk4      1/1       Running   0          22m
dask-worker-6457975f74-xzcmc      1/1       Running   0          22m
hub-7f75b59fc5-8c2pg              1/1       Running   0          6d
jupyter-zonca                     1/1       Running   0          10m
proxy-6bbf67f6bd-swt7f            2/2       Running   0          6d
```

### Access the scheduler and launch a distributed job

`kube-dns` gives a name to each service and automatically propagates it to each pod, so we can connect by name
```
from dask.distributed import Client
client = Client("dask-scheduler:8786")
client
```

Now we can access the 3 workers that we launched before:

```
Client
Scheduler: tcp://dask-scheduler:8786
Dashboard: http://dask-scheduler:8787/status
Cluster
Workers: 3
Cores: 6
Memory: 12.43 GB
```

We can run an example computation with dask array:

```
import dask.array as da
x = da.random.random((20000, 20000), chunks=(2000, 2000)).persist()
x.sum().compute()
```

### Access the Dask dashboard for monitoring job execution

We need to setup ingress so that a path points to the Dask dashboard instead of Jupyterhub,

Checkout the file `dask_shared/dask_webui_ingress.yaml` in the repository, it routes the path `/dask`
to the `dask-scheduler` service.

Create the ingress resource with:

    sudo kubectl create ingress -n pangeo -f dask_webui_ingress.yaml

All users can now access the dashboard at:

* <https://js-xxx-xxx.jetstream-cloud.org/dask/status>

Make sure to use `/dask/status/` and not only `/dask`.
Currently this is not authenticated, so this address is publicly available.
A simple way to hide it is to choose a custom name instead of `/dask` and edit
the ingress accordingly with:

    sudo kubectl edit ingress dask -n pangeo
