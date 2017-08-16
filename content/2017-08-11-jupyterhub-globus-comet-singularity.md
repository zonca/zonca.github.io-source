Title: Deployment of Jupyterhub with Globus Auth to spawn Notebook on Comet in Singularity containers
Date: 2017-08-11 18:00
Author: Andrea Zonca
Tags: jupyterhub, ansible, sdsc, singularity
Slug: jupyterhub-globus-comet-singularity

## Build Singularity containers to run single user notebook applications

Follow the instructions at <https://github.com/zonca/singularity-comet> to build images from the `ubuntu_anaconda_jupyterhub.def` and `centos_anaconda_jupyterhub.def` definition files, or use the containers I have already built on Comet:

    /oasis/scratch/comet/zonca/temp_project/centos_anaconda_jupyterhub.img
    /oasis/scratch/comet/zonca/temp_project/ubuntu_anaconda_cmb_jupyterhub.img

These containers have Centos 7 and Ubuntu 16.04 base images, MPI support (not needed for this), Anaconda 4.4.0, the Jupyterhub (for the `jupyterhub-singleuser` script) and Jupyterlab (for the awesomeness) packages.

## Initial setup of Jupyterhub with Ansible

First we want to use the Ansible playbook provided by the Jupyter team to setup a Ubuntu Virtual Machine, for example on SDSC Cloud or XSEDE Jetstream.
This sets up already a Jupyterhub instance on a single machine with Github authentication, NGINX with letsencrypt SSL and spawning of Notebooks as local processes.

Start from: [Automated deployment of Jupyterhub with Ansible](https://zonca.github.io/2017/02/automated-deployment-jupyterhub-ansible.html)

It looks like there is a compatibility error with `conda` 4.3 and above, I had to fix this (and provided PR upstream), I used the version at <https://github.com/zonca/jupyterhub-deploy-teaching/tree/globus_singularity>.
In particular check the example configuration file in the `host_vars/` folder.

Once we have executed the scripts, connect to the Virtual Machine, login with Github and check that Notebooks are working.

## Setup Authentication with Globus

Next we can SSH into the Jupyterhub Virtual Machine and customize Jupyterhub configuration in `/etc/jupyterhub`

`oauthenticator` should alrady be installed,, but it needs the Globus SDK to support authentication with Globus:

    sudo /opt/conda/bin/pip install globus_sdk[jwt]

Then follow the instructions to setup Globus Auth: <https://github.com/jupyterhub/oauthenticator#globus-setup>

you should now have add these lines in `/etc/jupyterhub/jupyterhub_config.py`

```
from oauthenticator.globus import GlobusOAuthenticator
c.JupyterHub.authenticator_class = GlobusOAuthenticator
c.GlobusOAuthenticator.oauth_callback_url = 'https://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu/hub/oauth_callback'
c.GlobusOAuthenticator.client_id = ''
c.GlobusOAuthenticator.client_secret = ''
```

You should now be able to login with your Globus ID credentials, see the documentation to support credentials from institutions supported by Globus Auth.
After login, don't worry if you get an error in starting your notebook.

## Setup Spawning with Batchspawner

In my last post about spawning Notebooks on Comet I was using XSEDE authentication so that each user would have to use their own Comet account.
In this scenario instead we imagine a Gateway system where the administrator shares their own allocation with the Gateway users. 
Therefore you should create a SSH keypair for the `root` user on the Jupyterhub Virtual Machine and make sure you can login with no need for a password to Comet as the Gateway user.

Then you need to install `batchspawner`:

    git clone https://github.com/jupyterhub/batchspawner.git
    cd batchspawner/
    sudo /opt/conda/bin/pip install .

Then configure the Spawner, see [my configuration of Jupyterhub: `jupyterhub_config.py`](https://gist.github.com/zonca/aaed55502c4b16535fe947791d02ac32).

You should modify `comet_spawner.py` to point to your Gateway user home folder and then fill all the details in `jupyterhub_config.py` marked by the `CONF` string.

In `CometSpawner` I also create a form for the user to choose the parameters of the job and also the Singularity image they want to use.

Here the spawner uses `SSH` to connect to the Comet login node and submit jobs as the Gateway user.

At this point you should be able to login and launch a job on Comet, execute `squeue` on Comet to check if that works or look in the home folder of the Gateway user for the logfile of the job and in `/var/log/jupyterhub` on the Virtual machine for errors.

## Setup tunneling

Finally we need a way for the gateway Virtual Machine to access the port on the Comet computing node in order to proxy the Notebook application back to the user.

The simpler solution is to create a user `tunnelbot` on the VM with no shell access, then create a SSH keypair and paste the **private** key into the `jupyterhub_config.py` file (contact me if you have a btter solution!).
The job on Comet sets up then a SSH tunnel between the Comet computing node and the Jupyterhub VM.

## Improvements

To keep the setup simple, all users are running on the home folder of the Gateway user, for a real deployment, it is possible to create a subfolder for each user beforehand and then use singularity to mount that as the home folder.
