Title: Deploy JupyterHub on Kubernetes deployment on Jetstream created with Kubespray 3/3
Date: 2018-09-24 1:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream, jupyterhub
Slug: kubernetes-jetstream-kubespray-jupyterhub

All of the following assumes you are logged in to the master node of the [Kubernetes cluster deployed with kubespray](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html) and checked out the repository:

<https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream>

## Install Jupyterhub

First run

```
bash create_secrets.sh
```

to create the secret strings needed by JupyterHub then edit its output
`secrets.yaml` to make sure it is consistent, edit the `hosts` lines if needed.

    bash configure_helm_jupyterhub.sh
    bash install_jhub.sh

Check some preliminary pods running with:

    kubectl get pods -n jhub

Once the `proxy` is running, even if `hub` is still in preparation, you can check
in browser, you should get "Service Unavailable" which is a good sign that
the proxy is working.

## Customize JupyterHub

After JupyterHub is deployed and integrated with Cinder for persistent volumes,
for any other customizations, first authentication, you are in good hands as the
[Zero-to-Jupyterhub documentation](https://zero-to-jupyterhub.readthedocs.io/en/stable/extending-jupyterhub.html) is great.

The only setup that could be peculiar to the deployment on top of `kubespray` is setup with HTTPS, see the next section.

## Setup HTTPS with letsencrypt

Kubespray instead of installing `kube-lego`, installs [`certmanager`](https://cert-manager.readthedocs.io/en/latest/index.html) to handle HTTPS certificates.

First we need to create a Issuer, set your email inside `setup_https_kubespray/https_issuer.yml` and create it with the usual:

    kubetcl create -f setup_https_kubespray/https_issuer.yml

Then we can manually create a HTTPS certificate, `certmanager` can be configured to handle this automatically, but as we only need a domain this is pretty quick, edit `setup_https_kubespray/https_certificate.yml` and set the domain name of your master node, then create the certificate resource with:

    kubetcl create -f setup_https_kubespray/https_certificate.yml

Finally we can configure JupyterHub to use this certificate, first edit your `secrets.yaml` following as an example the file `setup_https_kubespray/example_letsencrypt_secrets.yaml`, then update your JupyterHub configuration running again:

    bash install_jhub.sh

## Feedback

Feedback on this is very welcome, please open an issue on the [Github repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream) or email me at `zonca` on the domain of the San Diego Supercomputer Center (sdsc.edu).
