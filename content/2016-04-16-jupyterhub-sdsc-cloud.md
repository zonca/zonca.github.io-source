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
* add the hostname of the machine (check by running `hostname`) to `/etc/hosts`, i.e. the first line should become something like `127.0.0.1 localhost jupyterhub` if `jupyterhub` is the hostname

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
```

**SSL Certificate**: Letsencrypt is a lot more complex to setup, better self-signed.

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

* From: https://docs.docker.com/engine/installation/linux/ubuntulinux/#prerequisites

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

## Automatically start jupyterhub at boot

Save https://gist.github.com/zonca/aaeaf3c4e7339127b482d759866e5f39 as `/etc/init.d/jupyterhub`

```
sudo chmod +x /etc/init.d/jupyterhub
sudo service jupyterhub start
sudo update-rc.d jupyterhub defaults
```

# Connect to Jupyterhub

Open a browser and connect to the floating IP you set for your instance, this should redirect to the https, click "Advance" in the warning about safety due to the self signed SSL certificate and login with the training credentials.

Instead of using the IP, you can use any domain that points to that same IP with a DNS record of type A or get a dymanic DNS for free on a website like http://noip.com.

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

Also add `AllowUsers ubuntu` to `/etc/ssh/sshd_config` so that training users cannot SSH into the host machine.

# Optional: Add the R environment

* SSH into the instance
* `git clone https://github.com/jupyter/dockerspawner`
* `cd dockerspawner`

Modify the file `singleuser/Dockerfile`, replace `FROM jupyter/scipy-notebook` with `FROM jupyter/datascience-notebook`

    docker build -t datascience-singleuser singleuser

Modify the file `systemuser/Dockerfile`, replace `FROM jupyter/singleuser` with `FROM datascience-singleuser`

    docker build -t datascience-systemuser systemuser

 Finally in `jupyterhub_config.py`, select the new docker image:
 
    c.DockerSpawner.container_image = "datascience-systemuser"
