Title: Simulate users on JupyterHub
Date: 2019-10-30 12:00
Author: Andrea Zonca
Tags: kubernetes, openstack, jetstream, jupyterhub
Slug: loadtest-jupyterhub

I currently have 2 different strategies to deploy JupyterHub on top of Kubernetes on Jetstream:

* Using [Kubespray](https://zonca.github.io/2019/02/kubernetes-jupyterhub-jetstream-kubespray.html)
* Using [Magnum](http://zonca.github.io/2019/06/kubernetes-jupyterhub-jetstream-magnum.html), which also supports the [Cluster Autoscaler](http://zonca.github.io/2019/09/kubernetes-jetstream-autoscaler.html)

In this tutorial I'll show how to use Yuvi Pandas' [`hubtraf`](https://github.com/yuvipanda/hubtraf) to simulate load on JupyterHub, i.e. programmatically generate a predefined number of users connecting and executing notebooks on the system.

This is especially useful to test the Cluster Autoscaler.

`hubtraf` assumes you are using the Dummy authenticator, which is the default installed by the `zero-to-jupyterhub` helm chart. If you have configured another authenticator, temporarily disable it for testing purposes.

First go through the [`hubtraf` documentation](https://github.com/yuvipanda/hubtraf/blob/master/docs/index.rst#jupyterhub-traffic-simulator) to understand its functionalities.

`hubtraf` also has a Helm recipe to run it within Kubernetes, but the simpler way is to test from your laptop, follow the [documentation of `hubtraf`] to install the package and then run:

    hubtraf http://js-xxx-yyy.jetstream-cloud.org 2

To simulate 2 users connecting to the system, you can then check with:

    kubectl get pods -n jhub

That the pods are being created successfully and check the logs on the command line from `hubtraf` which explains what it is doing and tracks the time every operation takes, so it is useful to debug any delay in providing resources to users.

Consider that volumes created by JupyterHub for the test users will remain in Kubernetes and in Openstack, therefore if you would like to use the same deployment for production, remember to cleanup the Kubernetes `PersistentVolume` and `PersistentVolumeClaim` resources.

Now we can test scalability of the deployment with:

        hubtraf http://js-xxx-yyy.jetstream-cloud.org 100

Make sure you have asked the XSEDE support to increase the maximum number of volumes in Openstack in your allocation that by default is only 10.
