Title: Deploy Jupyterhub on SDSC Cloud
Date: 2016-04-16 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, sdsc
Slug: jupyterhub-sdsc-cloud

# Create a new Virtual Machine

* Login to the SDSC Cloud OpenStack dashboard
* Compute -> Access & Security -> Key Pairs -> Create key pair, name it `jupyterhub` and download it to your local machine
* Instances -> Launch Instance, Choose a name, Choose "Boot from image" in Boot Source and Ubuntu as Image name, Choose any size, depending on the number of users (TODO add link to Jupyterhub docs)
* Under "Access & Security" choose Key Pair `jupyterhub` and Security Groups `default`
* Click `Launch` to create the instance

# Give public IP to the instance

* Compute -> Access & Sewcurity -> Floating IPs -> Allocate IP To Project, "Allocate IP" to request a public IP
* Click on the "Associate" button of the IP just requested and under "Port to be associated"  choose the instance just created


* login into the Virtual Machine with `ssh -i jupyterhub.pem ubuntu@xxx.xxx.xxx.xxx` using the key file and the public IP setup in the previous steps
* 


# Install Docker

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

# Setup Jupyterhub

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

# Setup the web server

```
sudo apt install nginx
sudo apt install 
```

# SSL Certificate 

https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04

```
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

```

Get `/etc/nginx/nginx.conf` from https://gist.github.com/zonca/08c413a37401bdc9d2a7f65a7af44462
