Title: Scale Kubernetes manually on Jetstream
Date: 2019-02-22 21:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream, jupyterhub
Slug: scale-kubernetes-jupyterhub-manually

We would like to modify the number of Openstack virtual machines available to Kubernetes.
Ideally we would like to do this automatically based on the load on JupyterHub, that is the
target.
For now we will increase and decrease the size manually.
This can be useful for example if you make a test deployment with only 1 worker node a week
before a workshop and then scale it up to 10 or more instances the day before the workshop
begins.

This assumes you have [deployed Kubernetes and JupyterHub already](http://zonca.github.io/2019/02/kubernetes-jupyterhub-jetstream-kubespray.html)

## Create a new Openstack Virtual Machine with Terraform

To add nodes, enter the `inventory/$CLUSTER` folder, we can edit `cluster.tf` and increase `number_of_k8s_nodes_no_floating_ip`, in my testing I have increased it from 1 to 3.

Then we can run again `terraform_apply.sh`, this should run Terraform and create a new resource:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Check first that your machine has booted correctly running:

    openstack server list

```
+--------------------------------------+---------------------+--------+--------------------------------------------+-------------------------------------+----------+
| ID                                   | Name                | Status | Networks                                   | Image                               | Flavor   |
+--------------------------------------+---------------------+--------+--------------------------------------------+-------------------------------------+----------+
| 4ea73e65-2bff-42c9-8c4b-6c6928ad1b77 | zonca-k8s-node-nf-3 | ACTIVE | zonca_k8s_network=10.0.0.7                 | JS-API-Featured-Ubuntu18-Dec-7-2018 | m1.small |                                                       | 0cf1552e-ef0c-48b0-ac24-571301809273 | zonca-k8s-node-nf-2 | ACTIVE | zonca_k8s_network=10.0.0.11                | JS-API-Featured-Ubuntu18-Dec-7-2018 | m1.small |                                                       | e3731cde-cf6e-4556-8bda-0eebc0c7f08e | zonca-k8s-master-1  | ACTIVE | zonca_k8s_network=10.0.0.9, xxx.xxx.xxx.xx | JS-API-Featured-Ubuntu18-Dec-7-2018 | m1.small |
| 443c6861-1a13-4080-b5a3-e005bb34a77c | zonca-k8s-node-nf-1 | ACTIVE | zonca_k8s_network=10.0.0.3                 | JS-API-Featured-Ubuntu18-Dec-7-2018 | m1.small |
+--------------------------------------+---------------------+--------+--------------------------------------------+-------------------------------------+----------+
```

As expected we have now 1 master and 3 nodes.

Then change the folder to the root of the repository and check you can connect to it with:

    ansible -i inventory/$CLUSTER/hosts -m ping all

If any of the new nodes is Unreachable, you can try rebooting them with:

    openstack server reboot zonca-k8s-node-nf-3

### Configure the new instances for Kubernetes

`kubespray` has a special playbook `scale.yml` that impacts as little as possible the nodes
already running.
I have created a script `k8s_scale.sh` in the root folder of my `jetstream_kubespray` repository,
launch:

    bash k8s_scale.sh

[See for reference the `kubespray` documentation](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting-started.md#adding-nodes)

Once this completes (re-run it if it stops at some point), you should see what Ansible modified:

```
zonca-k8s-master-1         : ok=25   changed=3    unreachable=0    failed=0                                   zonca-k8s-node-nf-1        : ok=247  changed=16   unreachable=0    failed=0
zonca-k8s-node-nf-2        : ok=257  changed=77   unreachable=0    failed=0                                   zonca-k8s-node-nf-3        : ok=257  changed=77   unreachable=0    failed=0
```

At this point you should check the nodes are seen by Kubernetes with `kubectl get nodes`:

```
NAME                  STATUS   ROLES    AGE     VERSION                                                       zonca-k8s-master-1    Ready    master   4h29m   v1.12.5                                                       zonca-k8s-node-nf-1   Ready    node     4h28m   v1.12.5                                                       zonca-k8s-node-nf-2   Ready    node     5m11s   v1.12.5                                                       zonca-k8s-node-nf-3   Ready    node     5m11s   v1.12.5
```

## Reduce the number of nodes

Kubernetes is built to be resilient to node losses, so you could just brutally delete a node with `openstack server delete`. However, there is a dedicated playbook, `remove-node.yml`, to remove a node cleanly migrating any running services to other nodes and lowering the risk of anything malfunctioning.
I created a script `k8s_remove_node.sh`, pass the name of the node you would like to eliminate (or a comma separated list of many names):

    bash k8s_remove_node.sh zonca-k8s-node-nf-3

Now the node has disappeared by `kubectl get nodes` but the underlying Openstack instance is still running, delete it with:

    openstack server delete zonca-k8s-node-nf-3

For consistency you could now modify `inventory/$CLUSTER/cluster.tf` and reduce the number of nodes accordingly.
