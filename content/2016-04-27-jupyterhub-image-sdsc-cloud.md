Title: Quick Jupyterhub deployment for workshops with pre-built image
Date: 2016-04-28 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, sdsc
Slug: jupyterhub-image-sdsc-cloud

This tutorial explains how to use a OpenStack image I already built to quickly deploy a Jupyterhub Virtual Machine that can provide a good initial setup for a workshop, providing students access to Python 2/3, Julia, R, file editor and terminal with bash.

For details about building the instance yourself for more customization, see the full tutorial at <http://zonca.github.io/2016/04/jupyterhub-sdsc-cloud.html>.

## Create a Virtual Machine in OpenStack with the pre-built image

Follow the 3 steps at [the step by step tutorial](http://zonca.github.io/2016/04/jupyterhub-sdsc-cloud.html>) under "Create a Virtual Machine in OpenStack":

   * Network setup
   * Create a new Virtual Machine: here instead of choosing the base `ubuntu` image, choose `jupyterhub_docker`, also you can choose any size, I recommend to start with a `c1.large` for experimentation, you can then resize it later to a more powerful instance depending on the needs of your workshop
   * Give public IP to the instance
   
## Connect to Jupyterhub

The Jupyterhub instance is ready! Just open your browser and connect to the floating IP of the instance you just created.

The browser should show a security error related to the fact that the pre-installed SSL certificate is not trusted, click on "Advanced properties" and choose to connect anyway, we'll see later how to fix this.

You already have 50 training users, named `training01` to `training50`, all with the same password `jupyterhubSDSC` (see below how to change it). Check that you can login and create a notebook.

## Administer the Jupyterhub instance

Login into the Virtual Machine with `ssh -i jupyterhub.pem ubuntu@xxx.xxx.xxx.xxx` using the key file and the public IP setup in the previous steps.

To get rid of the annoying "unable to resolve host" warning, add the hostname of the machine (check by running hostname) to `/etc/hosts`, i.e. the first line should become something like `127.0.0.1 localhost jupyterhub` if jupyterhub is the hostname

### Change password/add more users

In the home folder of the `ubuntu` users, there is a file named `create_users.sh`, edit it to change the `PASSWORD` variable and the number of users from `50` to a larger number. Then run it with `bash create_users.sh`. Training users **cannot SSH** into the machine.

Use `sudo passwd trainingXX` to change the password of a single user.

### Setup a domain (needed for SSL certificate)

If you do not know how to get a domain name, here some options:

    * you can generally request a subdomain name from your institution, see for example [UCSD](http://blink.ucsd.edu/technology/help-desk/sysadmin-resources/domain.html#Register-your-domain-name)
    * if you own a domain, go in the DNS settings, add a record of type A to a subdomain, like `jupyterhub.yourdomain.com` that points to the floating IP of the Jupyterhub instance
    * you can get a free dynamic dns at websites like [noip.com](https://noip.com)
    
In each case you need to have a DNS record of type A that points to the floating IP of the Jupyterhub instance.

### Setup a SSL Certificate

[Letsencrypt](https://letsencrypt.org/) provides free SSL certificates by using a command line client.

SSH into the server, run:

    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    sudo service nginx stop
    ./letsencrypt-auto certonly --standalone -d jupyterhubdeploy.ddns.net
    
Follow instructions at the terminal to obtain a certificate

Now open the nginx configuration file: `sudo vim /etc/nginx/nginx.conf`

And modify the SSL certificate lines:

    ssl_certificate /etc/letsencrypt/live/yoursub.domain.edu/cert.pem;
    ssl_certificate_key /etc/letsencrypt/live/yoursub.domain.edu/privkey.pem;
    
Start NGINX:

    sudo service nginx start

Connect again to Jupyterhub and check that your browser correctly detects that the HTTPS connection is safe.

## Comments? Suggestions?

* [Twitter](http://twitter.com/andreazonca)
* Email `zonca` on the domain `sdsc.edu`
