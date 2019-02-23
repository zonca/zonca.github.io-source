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
`secrets.yaml` to make sure it is consistent, edit the `hosts` lines if needed. For example, supply the Jetstream DNS name of the master node `js-XXX-YYY.jetstream-cloud.org` (XXX and YYY are the last 2 groups of the floating IP of the instance AAA.BBB.XXX.YYY). See [part 2](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray-explore.html), "Publish service externally with ingress".

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

    kubectl create -f setup_https_kubespray/https_issuer.yml

Then we can manually create a HTTPS certificate, `certmanager` can be configured to handle this automatically, but as we only need a domain this is pretty quick, edit `setup_https_kubespray/https_certificate.yml` and set the domain name of your master node, then create the certificate resource with:

    kubectl create -f setup_https_kubespray/https_certificate.yml

Finally we can configure JupyterHub to use this certificate, first edit your `secrets.yaml` following as an example the file `setup_https_kubespray/example_letsencrypt_secrets.yaml`, then update your JupyterHub configuration running again:

    bash install_jhub.sh

## Setup HTTPS with custom certificates

In case you have custom certificates for your domain, first create a secret in the jupyterhub namespace with:

    kubectl create secret tls cert-secret --key ssl.key --cert ssl.crt -n jhub

Then setup ingress to use this in `secrets.yaml`:


```
ingress:
  enabled: true
  hosts:
    - js-XX-YYY.jetstream-cloud.org
  tls:
  - hosts:
    - js-XX-YYY.jetstream-cloud.org
    secretName: cert-secret
```

## Modify the Kubernetes cluster size

See a followup short tutorial on [scaling Kubernetes manually](https://zonca.github.io/2019/22/scale-kubernetes-jupyterhub-manually.html).

## Feedback

Feedback on this is very welcome, please open an issue on the [Github repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream) or email me at `zonca` on the domain of the San Diego Supercomputer Center (sdsc.edu).
