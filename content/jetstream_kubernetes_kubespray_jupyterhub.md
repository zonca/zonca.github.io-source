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

Eventually, you may need to update the certificate. This can be achieved with:

```
kubectl create secret tls cert-secret --key ssl.key --cert ssl.crt -n jhub \
    --dry-run -o yaml | kubectl apply -f -
```

## Modify the Kubernetes cluster size

See a followup short tutorial on [scaling Kubernetes manually](https://zonca.github.io/2019/02/scale-kubernetes-jupyterhub-manually.html).

## Persistence of user data

When a JupyterHub user logs in for the first time, a Kubernetes `PersistentVolumeClaim` of the size defined in the configuration file is created. This is a Kubernetes resource that defines a request for storage.

```
kubectl get pvc -n jhub
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
claim-zonca   Bound    pvc-c469967a-3968-11e9-aaad-fa163e9c7d08   1Gi        RWO            standard       2m34s
hub-db-dir    Bound    pvc-353114a7-3968-11e9-aaad-fa163e9c7d08   1Gi        RWO            standard       6m34s
```

Inspecting the claims we find out that we have a claim for the user and a claim to store the database of JupyterHub. Currently they are already Bound because they are already satistied.

Those claims are then satisfied by our Openstack Cinder provisioner to create a Openstack volume and wrap it into a Kubernetes `PersistentVolume` resource:

```
kubectl get pv -n jhub
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   REASON   AGE
pvc-353114a7-3968-11e9-aaad-fa163e9c7d08   1Gi        RWO            Delete           Bound    jhub/hub-db-dir    standard                8m52s
pvc-c469967a-3968-11e9-aaad-fa163e9c7d08   1Gi        RWO            Delete           Bound    jhub/claim-zonca   standard                5m4s
```

This corresponds to Openstack volumes automatically mounted onto the node that is executing the user pod:

```
+--------------------------------------+-------------------------------------------------------------+-----------+------+----------------------------------------------+
| ID                                   | Name                                                        | Status    | Size | Attached to                                  |
+--------------------------------------+-------------------------------------------------------------+-----------+------+----------------------------------------------+
| e6eddaaa-d40d-4832-addd-a05343ec3a80 | kubernetes-dynamic-pvc-c469967a-3968-11e9-aaad-fa163e9c7d08 | in-use    |    1 | Attached to zonca-k8s-node-nf-1 on /dev/sdc  |
| 00f1e822-8098-4633-804e-46ba44d7de7e | kubernetes-dynamic-pvc-353114a7-3968-11e9-aaad-fa163e9c7d08 | in-use    |    1 | Attached to zonca-k8s-node-nf-1 on /dev/sdb  |
```

If the user disconnects, the Openstack volume is un-attached from the instance but it is not delete and it is mounted back, optionally on another instance, if the user logs back in.

### Delete and reinstall JupyterHub

Helm release deleted:

    helm delete --purge jhub

As long as you do not delete the whole namespace, the volumes are not deleted, therefore you can re-deploy the same version or a newer version using `helm` and the same volume is mounted back for the user

### Delete and recreate Openstack instances

When we run terraform to delete all Openstack resources:

    bash terraform_destroy.sh

this does not include the Openstack volumes that are created by the Kubernetes persistent volume provisioner.

In case we are interested in keeping the same ip address, run instead:

    bash terraform_destroy_keep_floatingip.sh

The problem is that if we recreate Kubernetes again, it doesn't know how to link the Openstack volume to the Persistent Volume of a user.
Therefore we need to backup the Persistent Volumes and the Persistent Volume Claims resources before tearing Kubernetes down:

    kubectl get pvc -n jhub -o yaml > pvc.yaml
    kubectl get pv -n jhub -o yaml > pv.yaml

I recommend always to run `kubectl` on the local machine instead of the master node, because if you delete the master instance you loose any temporary modification to your scripts. In this case, even more importantly, if you are running on the master node please backup `pvc.yaml` and `pv.yaml` locally before running `terraform_destroy.sh` or they will be wiped out.

Then open the files with a text editor and delete the Persistent Volume and the Persistent Volume Claim related to `hub-db-dir`.

Edit `pv.yaml` and set:

      persistentVolumeReclaimPolicy:Retain

Otherwise if you create the PV first, it is deleted because there is no PVC.

Also remove the `ClaimRef` section of all the volumes in `pv.yaml`, otherwise you get the error "two claims are bound to the same volume, this one is bound incorrectly" on the PVC.

Now we can proceed to create the cluster again and then restore the volumes with:

    kubectl apply -f pv.yaml
    kubectl apply -f pvc.yaml


## Feedback

Feedback on this is very welcome, please open an issue on the [Github repository](https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream) or email me at `zonca` on the domain of the San Diego Supercomputer Center (sdsc.edu).
