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

Make sure you have asked the XSEDE support to increase the maximum number of volumes in Openstack in your allocation that by default is only 10. Otherwise edit `config_standard_storage.yaml` and set:

    singleuser:
      storage:
        type: none

## Test the Cluster Autoscaler

If you followed the tutorial to deploy the Cluster Autoscaler on Magnum, you can launch `hubtraf` to create a large number of pods, then check that some pods are "Running" and the ones that do not fit in the current nodes are "Pending":

    kubectl get pods -n jhub

and then check in the logs of the autoscaler that it detects that those pods are pending and requests additional nodes.
For example:

```bash
> kubectl logs -n kube-system cluster-autoscaler-hhhhhhh-uuuuuuu
I1031 00:48:39.807384       1 scale_up.go:689] Scale-up: setting group DefaultNodeGroup size to 2
I1031 00:48:41.583449       1 magnum_nodegroup.go:101] Increasing size by 1, 1->2
I1031 00:49:14.141351       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_IN_PROGRESS status
```

After 4 or 5 minutes the new node should be available and should show up in:

    kubectl get nodes

And we can check that some user pods are now running on the new node:

    kubectl get pods -n jhub -o wide

In my case the Autoscaler actually requested a 3rd node to accomodate all the users pods:

```bash
I1031 00:48:39.807384       1 scale_up.go:689] Scale-up: setting group DefaultNodeGroup size to 2
I1031 00:48:41.583449       1 magnum_nodegroup.go:101] Increasing size by 1, 1->2
I1031 00:49:14.141351       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_IN_PROGRESS status
I1031 00:52:51.308054       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_COMPLETE status
I1031 00:53:01.315179       1 scale_up.go:689] Scale-up: setting group DefaultNodeGroup size to 3
I1031 00:53:02.996583       1 magnum_nodegroup.go:101] Increasing size by 1, 2->3
I1031 00:53:35.607158       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_IN_PROGRESS status
I1031 00:56:41.834151       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_COMPLETE status
```

Moreover Cluster Autoscaler also provides useful information in the status of each "Pending" node. For example if it detects that it is useless to create a new node because the node is "Pending" for some other reason (e.g. volume quota reached), this infomation will be accessible using:

    kubectl describe node -n jhub jupyter-xxxxxxx

When the simulated users disconnect, `hubtraf` has a default of about 5 minutes, the autoscaler waits for the configured amount of minutes, by default it is 10 minutes, in my deployment it is 1 minute to simplify testing, see the `cluster-autoscaler-deployment-master.yaml` file.
After this delay, the autoscaler scales down the size of the cluster, it is a 2 step process, it first terminates the Openstack Virtual machine and then adjusts the size of the Magnum cluster (`node_count`), you can monitor the process using `openstack server list` and `openstack coe cluster list`, and the log of the autoscaler:

```bash
I1101 06:31:10.223660       1 scale_down.go:882] Scale-down: removing empty node k8s-e2iw7axmhym7-minion-1 
I1101 06:31:16.081223       1 magnum_manager_heat.go:276] Waited for stack UPDATE_IN_PROGRESS status
I1101 06:32:17.061860       1 magnum_manager_heat.go:276] Waited for stack UPDATE_COMPLETE status
I1101 06:32:49.826439       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_IN_PROGRESS status
I1101 06:33:21.588022       1 magnum_nodegroup.go:67] Waited for cluster UPDATE_COMPLETE status
```

## Acknowledgments

Thanks Yuvi Panda for providing `hubtraf`, thanks Julien Chastang for testing my deployments.
