Title: Deploy JupyterHub on a Supercomputer for a workshop or tutorial 2018 edition
Date: 2018-11-7 11:00
Author: Andrea Zonca
Tags: jupyterhub, comet, xsede
Slug: jupyterhub-supercomputer

I described how to deploy JupyterHub with each user session running on a different
node of a Supercomputer in [my paper for PEARC18](https://arxiv.org/abs/1805.04781),
however things are moving fast in the space and I am employing a different strategy
this year, in particular relying on [the littlest JupyterHub project](https://the-littlest-jupyterhub.readthedocs.io)
for the initial deployment.

## Initial deployment of JupyterHub

[The littlest JupyterHub project](https://the-littlest-jupyterhub.readthedocs.io) has great documentation
on how to deploy JupyterHub working on a single server on a wide array of providers.

In my case I logged in to the [dashboard](https://dashboard.cloud.sdsc.edu/) of [SDSC Cloud](http://www.sdsc.edu/services/ci/cloud.html), a OpenStack
deployment at the San Diego Supercomputer Center, and requested an instance with 16 GB of RAM and 6 vCPUs with Ubuntu 18.04. Make sure you attach a floating public IP to the instance and open up ports 22 for SSH and 80,443 for HTTP/HTTPS.

Then I followed the [installation tutorial for custom servers](https://the-littlest-jupyterhub.readthedocs.io/en/latest/install/custom-server.html), just make sure that you first create in the virtual machine the admin user you specify in the installation script, also
make sure to use the same username of your Github account, as we will later setup Github Authentication.

You can connect to the instance and check JupyterHub is working and you can login with your user and access the admin panel,
for SDSC Cloud the address is `http://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu`, filled in with the instance floating IP address.

### Setup HTTPS

Follow the Littlest JupyterHub documentation on how to get a SSL certificate through Letsencrypt automatically, after this you should be able to access JupyterHub from `https://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu` or a custom domain you pointed there.

## Authentication with Github

Follow the Littlest JupyterHub documentation, just make sure to set the `http` address and not the `https` address.

## Interface with Comet via batchspawner

We want all users to run on Comet as a single "Gateway" user, as JupyterHub executes as the `root` user on the server, we want to create a SSH key for the `root` user and copy the public key to the home folder of the gateway user on Comet so that we can SSH without a password.

Instead, if you would like each user to utilize their own XSEDE account, you need them to authenticate via XSEDE and get a certificate from the XSEDE API that can be used to login to Comet on behalf of the user, see [an example deployment of this](https://github.com/jupyterhub/jupyterhub-deploy-hpc/tree/master/batchspawner-xsedeoauth-sshtunnel-sdsccomet).

First install `batchspawner` with `pip` in the Python environment of the hub, this is different than the Python environment of the user, you can have access to it logging in with the `root` user and running:

    export PATH=/opt/tljh/hub/bin:${PATH}

Set the configuration file, see [`spawner.py` on this Gist](https://gist.github.com/zonca/55f7949983e56088186e99db53548ded) and copy it into the `/opt/tljh/config/jupyterhub_config.d` folder, then add the private SSH key of the tunnelbot user, which is a user on the Virtual Machine with no shell (set `/bin/false` in `/etc/passwd`) but that can setup a SSH tunnel from Comet back to the Hub.

Also customize all paths and usernames in the file.

Reload the Jupyterhub configuration with:

    tljh-config reload

You can then check the Hub logs with `sudo journalctl -r -u jupyterhub`

The most complicated part is making sure that the environment variables defined by JupyterHub, the most important is the token which allows the singleuser server to authenticate itself with the Hub, are correctly propagated through SSH. See in `spawner.py` how I explicitely pass the variables over SSH.

Also, as all workshop participants access Comet with the same user account, I automatically create a folder with their Github username and checkout the Notebooks for the workshop in that folder. Then start JupyterLab in that folder, so that the users do not interfere, we are not worrying about security here, with the current setup a user can open a terminal inside JupyterLab and access the folder of another person.

## How to setup the tunnelbot user

* On the JupyterHub virtual machine, create a user named `tunnelbot`
* `sudo su tunnelbot` to act as that user, then create a key with `ssh-keygen`
* enter the `.ssh` folder and `cp id_rsa.pub authorized_keys` so that the ssh key can be used from Comet to ssh passwordless to the server
* now get the **private key** from `/home/tunnelbot/.ssh/id_rsa` and paste it into `spawner.py`
* now make sure you set the shell of `tunnelbot` to `/bin/false` in `/etc/passwd/`
* for increased security, please also follow the steps in [this stackoverflow answer](https://askubuntu.com/questions/48129/how-to-create-a-restricted-ssh-user-for-port-forwarding)

## Acknowledgments

Thanks to the Jupyter and JupyterHub teams for releasing great software with outstanding documentation, in particular Yuvi Panda for the simplicity and elegance in the design of the Littlest JupyterHub deployment.
