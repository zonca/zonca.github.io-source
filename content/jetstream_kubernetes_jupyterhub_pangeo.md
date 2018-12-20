Title: Deploy Pangeo on Kubernetes deployment on Jetstream created with Kubespray
Date: 2018-12-20 1:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream, jupyterhub
Slug: kubernetes-jetstream-kubespray-pangeo

The [Pangeo collaboration for Big Data Geoscience](http://pangeo.io/) maintains a helm
chart with a prefigured JupyterHub deployment on Kubernetes which also supports launching
private dask workers.
This is very useful because the Jupyter Notebook users can launch a cluster of worker
containers inside Kubernetes and process larger amounts of data than they could using only
their notebook container.

## Setup Kubernetes on Jetstream with Kubespray

First check out my [tutorial on deploying Kubernetes on Jetstream with Kubespray](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html).
You just need to complete the first part, **do not install** JupyterHub, it is installed
as part of the Pangeo deployment.

## Install Pangeo with Helm

Pangeo publishes a [Helm chart](https://github.com/pangeo-data/helm-chart) (a software package for Kubernetes) and we can leverage that
to setup the deployment.

First add the repository:

    helm repo add pangeo https://pangeo-data.github.io/helm-chart/
    helm repo update

Then download my repository with all the configuration files and helper scripts:

    git clone https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream

Create a `secrets.yaml` file running:

    bash create_secrets.sh

Then head to the `pangeo_helm` folder and customize [`config_jupyterhub_pangeo_helm.yaml`](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/pangeo_helm/config_jupyterhub_pangeo_helm.yaml),

* I have prepopulated very small limits for testing, increase those for production
* I am using the docker image `zonca/pangeo_notebook_rsignell`, you can remove `image:` and the 2 lines below to use the standard Pangeo notebook image (defined in their [`values.yaml`](https://github.com/pangeo-data/helm-chart/blob/master/pangeo/values.yaml))
* Copy `cookieSecret` and `secretToken` from `secrets.yaml` you created above
* Customize `ingress` - `hosts` with the hostname of your master instance

Finally you can deploy it running:

    bash install_pangeo.sh

Login by pointing your browser at <http://js-XXX-YYY.jetstream-cloud.org>, the default dummy authenticator only needs a username and empty password.

## Customize and launch dask workers

Once you login to the Jupyter Notebook, you can customize the `worker-template.yaml` file available in your home folder,
I have [an example of it with very small limits](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/blob/master/pangeo_helm/worker_template.yaml) in the `pangeo_helm` folder.

This file is used by `dask_kubernetes` to launch workers on your behalf, see for example the `dask-array.ipynb` notebook available in your home folder:

```
from dask_kubernetes import KubeCluster
cluster = KubeCluster(n_workers=3)
cluster
```

This will launch 3 workers on the cluster which are then available to launch jobs on with [`dask`](https://dask.pydata.org).

You can check with `kubectl` that the workers are executing:

```
$ kubectl get pods -n pangeo
NAME                         READY   STATUS    RESTARTS   AGE
dask-zonca-d191b7a4-d8jhft   1/1     Running   0          28m
dask-zonca-d191b7a4-dx9dhs   1/1     Running   0          28m
dask-zonca-d191b7a4-dzmgvv   1/1     Running   0          28m
hub-55f5bf597-f5bnt          1/1     Running   0          55m
jupyter-zonca                1/1     Running   0          38m
proxy-66576956d7-r926j       1/1     Running   0          55m
```

And also access the Dask GUI, using the menu on the left or the link provided by `dask_kubernetes` inside the Notebook.

![Screenshot of the Dask UI](/images/dask_ui_workers.png)
