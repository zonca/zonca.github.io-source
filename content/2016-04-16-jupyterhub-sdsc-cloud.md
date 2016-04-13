Title: Deploy Jupyterhub on SDSC Cloud
Date: 2016-04-16 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, sdsc
Slug: jupyterhub-sdsc-cloud

# Create a Virtual Machine in OpenStack

* Login to the SDSC Cloud OpenStack dashboard

## Network setup

* Compute -> Access & Security -> Security Groups -> Create Security Group and name it `jupyterhubsecgroup`
* Click on Manage Rules 
* Click on add rule, choose the HTTP rule and click add
* Repeat the last step with HTTPS and SSH
* Click on add rule again, choose Custom TCP Rule, set port 8081 and set CIDR 172.17.0.0/24 (this is needed so that the containers can connect to the hub)

## Create a new Virtual Machine

* Compute -> Access & Security -> Key Pairs -> Create key pair, name it `jupyterhub` and download it to your local machine
* Instances -> Launch Instance, Choose a name, Choose "Boot from image" in Boot Source and Ubuntu as Image name, Choose any size, depending on the number of users (TODO add link to Jupyterhub docs)
* Under "Access & Security" choose Key Pair `jupyterhub` and Security Groups `jupyterhubsecgroup`
* Click `Launch` to create the instance

## Give public IP to the instance

* Compute -> Access & Sewcurity -> Floating IPs -> Allocate IP To Project, "Allocate IP" to request a public IP
* Click on the "Associate" button of the IP just requested and under "Port to be associated"  choose the instance just created

# Setup Jupyterhub in the Virtual Machine

* login into the Virtual Machine with `ssh -i jupyterhub.pem ubuntu@xxx.xxx.xxx.xxx` using the key file and the public IP setup in the previous steps

## Setup Jupyterhub

```
 wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
 bash Miniconda3-latest-Linux-x86_64.sh
 ```
 
 use all defaults, answer "yes" to modify PATH
 
 ```
sudo apt-get install npm nodejs-legacy
sudo npm install -g configurable-http-proxy
conda install traitlets tornado jinja2 sqlalchemy 
pip install jupyterhub
```

## Setup the web server

```
sudo apt install nginx
sudo apt install 
```

**SSL Certificate**: Letsencrypt is a lot more complex to setup, better self-signed.

https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04


```
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

```

Get `/etc/nginx/nginx.conf` from https://gist.github.com/zonca/08c413a37401bdc9d2a7f65a7af44462

For authentication to work, the `ubuntu` user needs to be able to read the `/etc/shadow` file:

```
sudo adduser ubuntu shadow
```

## Install Docker

* https://docs.docker.com/engine/installation/linux/ubuntulinux/#prerequisites

```
sudo apt update
sudo apt install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list 
sudo apt update
sudo apt install docker-engine
sudo usermod -aG docker ubuntu
```

Logout and login again for the group to take effect

## Install and configure DockerSpawner

```
pip install dockerspawner
docker pull jupyter/systemuser
conda install ipython jupyter
```

Create `jupyterhub_config.py` in the home folder of the ubuntu user with this content:

```
c.JupyterHub.confirm_no_ssl = True
c.JupyterHub.spawner_class = 'dockerspawner.SystemUserSpawner'

# The docker instances need access to the Hub, so the default loopback port doesn't work:
from IPython.utils.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0
```

# Create training user accounts

Add user accounts on Jupyterhub creating standard Linux users with `adduser` interactively or with a batch script.

For example the following batch script creates 10 users all with the same password:

```
#!/bin/bash
PASSWORD=samepasswordforallusers
NUMBER_OF_USERS=10
for n in `seq -f "%02g" 1 $NUMBER_OF_USERS`
do
    echo creating user training$n
    echo training$n:$PASSWORD::::/home/training$n:/bin/bash | sudo newusers
done
```
