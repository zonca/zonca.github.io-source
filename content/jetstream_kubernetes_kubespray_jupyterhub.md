Title: Deploy JupyterHub on Kubernetes deployment on Jetstream created with Kubespray 3/3
Date: 2018-09-24 1:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream, jupyterhub
Slug: kubernetes-jetstream-kubespray-jupyterhub

## Install Jupyterhub

    bash configure_helm_jupyterhub.sh
    bash install_jhub.sh

Check some preliminary pods running with:

    kubectl get pods -n jhub

Once the `proxy` is running, even if `hub` is still in preparation, you can check
in browser, you should get "Service Unavailable" which is a good sign that
the proxy is working.

