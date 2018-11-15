Title: Deploy Kubernetes on Jetstream with Kubespray 1/3
Date: 2018-09-23 18:00
Author: Andrea Zonca
Tags: kubernetes, kubespray, jetstream
Slug: kubernetes-jetstream-kubespray

The purpose of this tutorial series is to deploy Jupyterhub on top of
Kubernetes on Jetstream.
Compared to my [initial tutorial](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html), I focused on improving automation.
Instead of creating Jetstream instances via the Atmosphere web interface and then
SSHing into the instances and run `kubeadm` based commands to setup Docker and Kubernetes we will:

* Use the `terraform` recipe part of the `kubespray` project to interface with the Jetstream API and create a cluster of virtual machines
* Run the `kubespray` ansible recipe to setup a production-ready Kubernetes deployment, optionally with High Availability features like redundant master nodes and much more, see [kubepray.io](http://kubespray.io).

## Create Jetstream Virtual machines with Terraform

`kubespray` is able to deploy production-ready Kubernetes deployments and initially targeted only
commercial cloud platforms.

They recently added support for Openstack via a Terraform recipe which is available in [their Github repository](https://github.com/kubernetes-incubator/kubespray/tree/master/contrib/terraform/openstack).

Terraform allows to execute recipes that describe a set of OpenStack resources and their relationship. In the context of this tutorial, we do not need to learn much about Terraform, we will configure and execute the recipe provided by `kubespray`.

### Requirements

On a Ubuntu 18.04 install `python3-openstackclient` with APT.
Any other platform works as well, also install `terraform` by copying the correct binary to `/usr/local/bin/`, see <https://www.terraform.io/intro/getting-started/install.html>.

### Request API access

In order to make sure your XSEDE account can access the Jetstream API, you need to contact the Helpdesk, see the [instructions on the Jetstream Wiki](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/39682057/Using+the+Jetstream+API). You will also receive your **TACC** password, which could be different than your XSEDE one (username is generally the same).

Login to the TACC Horizon panel at <https://tacc.jetstream-cloud.org/dashboard>, this is basically the low level web interface to OpenStack, a lot more complex and powerful than Atmosphere available at <https://use.jetstream-cloud.org/application>. Use `tacc` as domain, your TACC username (generally the same as your XSEDE username) and your TACC password.

First choose the right project you would like to charge to in the top dropdown menu (see the XSEDE website if you don't recognize the grant code).

Click on Compute / API Access and download the OpenRC V3 authentication file to your machine. Source it typing:

    source XX-XXXXXXXX-openrc.sh

it should ask for your TACC password. This configures all the environment variables needed by the `openstack` command line tool to interface with the Openstack API.

Test with:

    openstack flavor list

This should return the list of available "sizes" of the Virtual Machines.

### Clone kubespray

I had to make a few modifications to `kubespray` to adapt it to Jetstream or backport bug fixes not merged yet, so currently better use my fork of `kubespray`:

    git clone https://github.com/zonca/jetstream_kubespray

See an [overview of my changes compared to the standard `kubespray` release 2.6.0](https://github.com/zonca/jetstream_kubespray/pull/2).

### Run Terraform

Inside `jetstream_kubespray`, copy from my template:

    export CLUSTER=$USER
    cp -LRp inventory/zonca_kubespray inventory/$CLUSTER
    cd inventory/$CLUSTER

Open and modify `cluster.tf`, choose your image and number of nodes.
Make sure to change the network name to something unique, like the expanded form of `$CLUSTER_network`.

You can find suitable images (they need to be JS-API-Featured, you cannot use the same instances used in Atmosphere):

    openstack image list | grep "JS-API"

I already preconfigured the network UUID both for IU and TACC, but you can crosscheck
looking for the `public` network in:

    openstack network list

Initialize Terraform:

    bash terraform_init.sh

Create the resources:

    bash terraform_apply.sh

The last output log of Terraform should contain the IP of the master node `k8s_master_fips`, wait for it to boot then
SSH in with:

    ssh ubuntu@$IP

or `centos@$IP` for CentOS images.

Inspect with Openstack the resources created:

    openstack server list
    openstack network list

You can cleanup the virtual machines and all other Openstack resources (all data is lost) with `bash terraform_destroy.sh`.

## Install Kubernetes with `kubespray`

Change folder back to the root of the `jetstream_kubespray` repository,

First make sure you have a recent version of `ansible` installed, you also need additional modules,
so first run:

    pip install -r requirements.txt

It is useful to create a `virtualenv` and install packages inside that.
This will also install `ansible`, it is important to install `ansible` with `pip` so that the path to access the modules is correct. So remove any pre-installed `ansible`.


Then following the [`kubespray` documentation](https://github.com/kubernetes-incubator/kubespray/blob/master/contrib/terraform/openstack/README.md#ansible), we setup `ssh-agent` so that `ansible` can SSH from the machine with public IP to the others:

    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa

Test the connection through ansible:

    ansible -i inventory/$CLUSTER/hosts -m ping all

If a server is not answering to ping, first try to reboot it:

    openstack server reboot $CLUSTER-k8s-node-nf-1

Or delete it and run `terraform_apply.sh` to create it again.

check `inventory/$CLUSTER/group_vars/all.yml`, in particular `bootstrap_os`, I setup `ubuntu`, change it to `centos` if you used the Centos 7 base image.

Due to a bug in the recipe, run ( see details in the Troubleshooting notes below):

    export OS_TENANT_ID=$OS_PROJECT_ID

Finally run the full playbook, it is going to take a good 10 minutes:

    ansible-playbook --become -i inventory/$CLUSTER/hosts cluster.yml

If the playbook fails with "cannot lock the administrative directory", it is due to the fact that the Virtual Machine is automatically updating so it has locked the APT directory. Just wait a minute and launch it again. It is always safe to run `ansible` multiple times.

If the playbook gives any error, try to retry the above command, sometimes there are temporary failed tasks, Ansible is designed to be executed multiple times with consistent results.

You should have now a Kubernetes cluster running, test it:

```
$ ssh ubuntu@$IP
$ kubectl get pods --all-namespaces
NAMESPACE       NAME                                                   READY     STATUS    RESTARTS   AGE
cert-manager    cert-manager-78fb746bc7-w9r94                          1/1       Running   0          2h
ingress-nginx   default-backend-v1.4-7795cd847d-g25d8                  1/1       Running   0          2h
ingress-nginx   ingress-nginx-controller-bdjq7                         1/1       Running   0          2h
kube-system     kube-apiserver-zonca-kubespray-k8s-master-1            1/1       Running   0          2h
kube-system     kube-controller-manager-zonca-kubespray-k8s-master-1   1/1       Running   0          2h
kube-system     kube-dns-69f4c8fc58-6vhhs                              3/3       Running   0          2h
kube-system     kube-dns-69f4c8fc58-9jn25                              3/3       Running   0          2h
kube-system     kube-flannel-7hd24                                     2/2       Running   0          2h
kube-system     kube-flannel-lhsvx                                     2/2       Running   0          2h
kube-system     kube-proxy-zonca-kubespray-k8s-master-1                1/1       Running   0          2h
kube-system     kube-proxy-zonca-kubespray-k8s-node-nf-1               1/1       Running   0          2h
kube-system     kube-scheduler-zonca-kubespray-k8s-master-1            1/1       Running   0          2h
kube-system     kubedns-autoscaler-565b49bbc6-7wttm                    1/1       Running   0          2h
kube-system     kubernetes-dashboard-6d4dfd56cb-24f98                  1/1       Running   0          2h
kube-system     nginx-proxy-zonca-kubespray-k8s-node-nf-1              1/1       Running   0          2h
kube-system     tiller-deploy-5c688d5f9b-fpfpg                         1/1       Running   0          2h
```

Compare that you have all those services running also in your cluster.
We have also configured NGINX to proxy any service that we will later deploy on Kubernetes,
test it with:

```
$ wget localhost
--2018-09-24 03:01:14--  http://localhost/
Resolving localhost (localhost)... 127.0.0.1
Connecting to localhost (localhost)|127.0.0.1|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
2018-09-24 03:01:14 ERROR 404: Not Found.
```

Error 404 is a good sign, the service is up and serving requests, currently there is nothing to deliver.
Finally test that the routing through the Jetstream instance is working correctly by opening your browser
and test that if you access `js-XX-XXX.jetstream-cloud.org` you also get a `default backend - 404` message.
If any of the tests hangs or cannot connect, there is probably a networking issue.

### Troubleshooting notes

For future reference, disregard this.

Failing ansible task: `openstack_tenant_id is missing`

fixed with: `export OS_TENANT_ID=$OS_PROJECT_ID`, this should be fixed once <https://github.com/kubernetes-incubator/kubespray/pull/2783> is merged, anyway this is not blocking.

Failing task `Write cacert file`:

NOTE: had to cherry-pick a commit from <https://github.com/kubernetes-incubator/kubespray/pull/3280>, this will be unnecessary once this is fixed upstream

## (Optional) Setup kubectl locally

We also set `kubectl_localhost: true` and `kubeconfig_localhost: true`.
so that `kubectl` is installed on your local machine

it also copies `admin.conf` to:

    inventory/$CLUSTER/artifacts

now copy that to `~/.kube/config`

this has an issue, it has the internal IP of the Jetstream master.
We cannot replace it with the public floating ip because the certificate is not valid for that.
Best workaround is to replace it with `127.0.0.1` inside `~/.kube/config` at the `server:` key.
Then make a SSH tunnel, we need `sudo` because it is a reserved port:

    sudo ssh ubuntu@FLOATINGIPOFMASTER -L 6443:localhost:6443

## (Optional) Setup helm locally

ssh into the master node, check helm version with:

    helm version

Download the same binary version from [the release page on Github](https://github.com/helm/helm/releases)
and copy the binary to `/url/local/bin`.

    helm ls
