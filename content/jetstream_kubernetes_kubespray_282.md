Title: Deploy Kubernetes with Kubespray 2.8.2 and JupyterHub with helm recipe 0.8 on Jetstream
Date: 2019-02-22 18:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream
Slug: kubernetes-jupyterhub-jetstream-kubespray

Back in September 2018 I published a [tutorial to deploy Kubernetes on Jetstream](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html) using Kubernetes.

Software in the Kubernetes space moves very fast, so I decided to update the recipe to use the newer Kubespray 2.8.2 that deploys Kubernetes v1.12.5.

Please follow the old tutorial and note the updates below.

### Switch to kubespray 2.8.2

Once you get my fork of kubespray with a few fixes for Jetstream:

    git clone https://github.com/zonca/jetstream_kubespray

**switch to the newer 2.8.2 version**

    git checkout -b branch_v2.8.2 origin/branch_v2.8.2

See an [overview of my changes compared to the standard `kubespray` release 2.8.2](https://github.com/zonca/jetstream_kubespray/pull/5).

### Use the new template

The name of my template is now just `zonca` instead of `zonca_kubespray`:

Before running Terraform, inside `jetstream_kubespray`, copy from my template:

    export CLUSTER=$USER
    cp -LRp inventory/zonca inventory/$CLUSTER
    cd inventory/$CLUSTER

### Explore kubernetes

In case you are interested in exploring some of the capabilities of Kubernetes, you can check [the second part of my tutorial](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-explore.html), nothing in this section is required to run JupyterHub.

### Install JupyterHub

Finally you can use `helm` to install JupyterHub, see the [last part of my tutorial](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-jupyterhub.html).

Consider that I have updated the repository <https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream> to install the `0.8.0` version of the `helm` package just released yesterday, see [their blog post with more details](https://blog.jupyter.org/zero-to-jupyterhub-helm-chart-0-8-b99e0a79fd2a).

### Thanks

Thanks to the Kubernetes, Kubespray and JupyterHub community for delivering great open-source software and to XSEDE for giving me the opportunity to work on this. Special thanks to my collaborators Julien Chastang and Rich Signell.
