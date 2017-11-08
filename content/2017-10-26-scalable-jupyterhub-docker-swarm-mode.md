Title: Deploy scalable Jupyterhub on Docker Swarm mode
Date: 2017-10-26 18:00
Author: Andrea Zonca
Tags: github, travis, git
Slug: scalable-jupyterhub-docker-swarm-mode

## Introduction

Jupyterhub genrally requires roughly 500MB per user for light data processing and many GB for heavy data processing, therefore it is often necessary to deploy it across multiple machines to support many users.

The recommended scalable deployment for Jupyterhub is on Kubernetes, see [Zero to Jupyterhub](https://zonca.github.io/2016/05/jupyterhub-docker-swarm.html) (and I'll cover it next). However the learning curve for Kubernetes is quite steep, I believe that for smaller deployments (30/50 users, 10 users per machine) and were high availability is not critical, deploying on Docker with Swarm Mode is a simpler option.

In the past I have covered a [Jupyterhub deployment on the old version of Docker Swarm](https://zonca.github.io/2016/05/jupyterhub-docker-swarm.html) using `DockerSpawner`. The most important difference is that the last version of Docker has a more sophisticated "Swarm mode" that allows you to launch and manage services instead of individual containers, support for this is provided by [`SwarmSpawner`](https://github.com/cassinyio/SwarmSpawner). Thanks to the new architecture, we do not need to have actual Unix accounts on the Host but all users can run with the `jovyan` user account defined only inside the Docker containers. Then we can also deploy Jupyterhub itself as a Docker container instead of installing it on the Host.

## Setup a Virtual Machine for the Hub

First of all we need to create a Virtual Machine, I tested this on XSEDE Jetstream CentOS 7 image (with Docker pre-installed), but I would recommend Ubuntu 16.04 which is more universally used so it is easier to find support for it.
The same setup would work on a bare-metal server.

Make sure that a recent version of Docker is installed, I used `17.07.0-ce`.

Setup networking so that port 80 and 443 are accessible for HTTP and HTTPS. Associate a Public IP to this instance so that it is accessible from the Internet.

Add your user to the `docker` group so you do not need `sudo` to run `docker` commands. Check that `docker` works running `docker info`.

### Clone the config files repository

I recommend to create the folder `/etc/jupyterhub`, set ownership to your user and clone my configuration repository there:

	git clone https://github.com/zonca/deploy-jupyterhub-dockerswarm /etc/jupyterhub

### Setup Swarm

The first node is going to be the *Master* node of the Swarm, launch:

    docker swarm init --advertise-addr INTERNAL_IP_ADDRESS

It is better to use a internal IP address, for example on Jetstream the `192.xxx.xxx.xxx` IP. This is the address that the other instances will use to connect to this node.

This command will print out the string that the other nodes will need to run to join this swarm, save it for later (you can recover it with `docker swarm join-token`)

### Install the NGINX web server

NGINX is going to sit in front of Jupyterhub as a proxy and handle SSL, we are going to have also NGINX as a Docker service:

    docker pull nginx:latest

Now let's test that Docker and the networking is working correctly, launch `nginx` with the default configuration:

	docker service create \
	  --name nginx \
	  --publish 80:80 \
	  nginx

This is going to create a service, then the service creates the containers, check with `docker service ls` and `docker ps`, if a container dies, the service will automatically relaunch it.
Now if you connect to your instance from an external machine you should see the NGINX welcome page.
If this is not the case check `docker ps -a` and `docker logs INSTANCE_ID` to debug the issue.

Finally remove the service with:

    docker service rm nginx

Now run the service with the configuration for Jupyterhub, edit `nginx.conf` and replace `SERVER_URL` then launch:

    bash ngnx_service.sh

At this point you should gate a Gateway error if you connect with a browser to your instance.

### Install Jupyterhub

Before launching Jupyterhub you need to create a Docker network so that the containers in the swarm can communicate easily:

    docker network create --driver overlay jupyterhub

You can launch the official Jupyterhub 0.8.0 container as a service with:

	docker service create \
	  --name jupyterhubserver \
	  --network jupyterhub \
	  --detach=true \
	  jupyterhub/jupyterhub:0.8.0


This would run Jupyterhub with the default `jupyterhub_config.py` with local auth and local spawner.
If you connect to the instance now you should see the Jupyterhub login page, you cannot login because you don't have
a user account inside the container. We'll setup authentication next.

#### Configure Jupyterhub

Next we want to customize the hub, first login on <http://hub.docker.com> and create a new repository,
then follow the instructions there to setup `docker push` on your server so you can push your image 
to the registy.

This is necessary because Swarm might spawn the service on a different machine, so itneeds an external
registry to make sure to pull the right image.

You can now customize the hub image in `/etc/jupyterhub/hub` with `docker build . -t yourusername/jupyterhub-docker`
and push it remotely with `docker push yourusername/jupyterhub-docker`.

This image includes `oauthenticator` for Github, Google, CILogon and Globus authentication and `swarmspawner` for
spawning containers for the users.

We can now create `jupyterhub_config.py`, for now we just want temporary home folders, so replace the `mounts` variable with `[]` in `c.SwarmSpawner.container_spec`. Then customize the server URL `server_url.com` and IP `SERVER_IP` (it will be necessary later).
At the bottom of `jupyterhub_config.py` we can also customize CPU and memory contraints. Unfortunately there is no easy way to setup a custom disk space limit.

Follow the documentation of `oauthenticator` to setup authentication.

Create the folder `/var/nfs` that we will configure later but it is harcoded in the script to launch the service.

Temporarily remove from `launch_service_jupyterhub.sh` the line:

    --mount src=nfsvolume,dst=/var/nfs \

Launch the service from `/etc/jupyterhub` with `bash launch_service_jupyterhub.sh`.

Check in the script that we are mounting the Docker socket into the container so that Jupyterhub can launch Docker containers for the users. We also mount the `/etc/jupyterhub` folder so that it has access to `jupyterhub_config.py`. We also contraint it to run in the manager node of this Swarm, this assures that it always runs on this first node. We could later add another manager node for resiliency and the Hub could potentially spawn there with no issues.

At this point we have a first working configuration of Jupyterhub, try to login and check if the notebooks are working.
This configuration has no permanent storage, so the users will have a home folder inside their container and will be able to
write Notebooks and data there up to the image reaching 10GB, so about 5GB.
If they logout and log back in they will find their files still there, but if they do "Close my Server" from the control panel
or if for any other reason their container is removed, they will loose their data.
So this setup could be used for short workshops or demos.

## Setup other nodes

We can create another Virtual Machine with the same version of Docker and make sure that the two machines internally have all the port open to simplify networking. Any additional machine **needs no open ports** to the outside world, all connections will go through nginx.

We can have it join the Swarm by pasting the token got at Swarm initialization on the first node.

Now when Jupyterhub launches a single user container, it could spawn either on this server or on the first server, Swarm will automatically take care of load balancing. It will also automatically download the Docker image specified in `jupyterhub_config.py`.

We can add as many nodes as necessary.

## Setup Permanent storage

Surprisingly enough, Swarm has no easy way to setup permament storage that would automatically move data from one node to another in case a user container is re-spawned on another server. There are some volume plugins but I believe that their configuration is so complex that at this point would be better to directly switch to Kubernetes.
In order to achieve a simpler setup that I believe could easily handle few tens of users we can use NFS. Moreover Docker volumes can handle NFS natively, so we don't even need to have home folders owned by each user but we can just point Docker volumes to our NFS folder and Docker will manage that for us and we can just use one single user. Users cannot access other people's files because only their own folder is mounted into their container.

### Setup a NFS server

First we need to decide which server acts as NFS server, for small deployments we can have just the first server which runs the hub also handle this, for more performance we might want to have a dedicated server that only runs NFS and which is part of the internal network but does not participate in the Swarm so that it won't have user containers running on it.

In a Cloud environment like Jetstream or Amazon, it is useful to create a Volume and attach it to that instance so that we can enlarge it later or back it up independently from the Instance and that would survive the Hub instance. Make sure to choose the XFS filesystem if you need to setup disk space contraints. Mount it in `/var/nfs/` and make sure it is writable by any user.

On that server we can install NFS following the OS instructions and setup `/etc/exports` with:

    /var/nfs        *(rw,sync,no_subtree_check)

The NFS port is accessible only on the internal network anyway so we can just accept any connection.

SSH into any of the Swarm nodes and check this works fine with:

    sudo mount 192.NFS.SRV.IP:/var/nfs /mnt
    touch /mnt/writing_works

### Setup Jupyterhub to use Docker Volumes over NFS

In `/etc/jupyterhub/jupyterhub_config.py` we should configure the mounts to `swarmspawner`:

	mounts = [{'type': 'volume',
			   'source': 'jupyterhub-user-{username}',
			   'target': notebook_dir,
			'no_copy' : True,
			'driver_config' : {
			  'name' : 'local',
			  'options' : {
				 'type' : 'nfs4',
				 'o' : 'addr=SERVER_IP,rw',
				 'device' : ':/var/nfs/{username}/'
			   }
			},
	}]

Replace `SERVER_IP` with your server, this tells the Docker `local` Volume driver to mount folders `/var/nfs/{username}` as home folders of the single user notebook container.

The only problem is that these folders need to be pre-existing, so I modified the `swarmspawner` plugin to create those folders the first time a user authenticates, please let me know if there is a better way and I'll improve this tutorial.
See the branch `createfolder` on [my fork of `swarmspawner`](https://github.com/zonca/SwarmSpawner/tree/createfolder).
In order to install this you need to modify your custom `jupyterhub-docker` to install from there (see the commented out section in `hub/Dockerfile`).
Often the `Authenticator` transform the username into a hash, so I added a feature on this spawner to also create a text file `HASH_email.txt` and save the email of the user there so that it is easier to check directly from the filesystem who owns a specific folder.

For this to work the Hub needs access to `/var/nfs/`, the best way to achieve this is to create another Volume, add the `NFS_SERVER_IP` and launch on the first server:

    bash create_volume_nfs.sh

Then uncomment the `--mount src=nfsvolume,dst=/var/nfs \` line from `launch_service_jupyterhub.sh` and relaunch the service so that it is available locally.

At this point you should test that if you login, then stop/kill the container, your data should still be there when you launch it again.

### Setup user quota

The Docker local Volume driver does not support setting a user quota so we have to resort to our filesystem. You can modify `/etc/fstab` to mount the XFS volume with the `pquota` option that supports setting a limit to a folders and all of its subfolders. We cannot use user quotas because all of the users are running under the same UNIX account.

Create a folder `/var/nfs/testquota` and then test that setting quota is working with:

    sudo set_quota.sh /var/nfs testquota

There should be a space between `/var/nfs` and `testquota`, then check with:

    bash get_quota.sh

You should see a quota of `1GB` for that folder. Modify `set_quota.sh` to choose another size.

#### Automatically set quotas

We want quota to be automatically set each time the spawner creates another folder, `incrond` can monitor a folder for any new created file and launch the `set_quota.sh` script for us.

Install the `incrond` package and make sure it is active and restarted on boot. Then customize it with `sudo incrontab -e` and paste the content of `incrontab` in `/etc/jupyterhub`.

Now delete your user folder in `/var/nfs` and launch Jupyterhub again to check that the folder is created with the correct quota. The spawner also creates a `/var/nfs/{username}_QUOTA_NOT_SET` that is deleted then by the `set_quota.sh` script.

## Setup HTTPS

We would like to setup NGINX to provide SSL encryption for Jupyterhub using the free Letsencrypt service. The main issue is that those certificates need to be renewed every few months, so we need a service running regularly to take care of that.

The simplest option would be to add `--publish 8000` to the Jupyterhub so that Jupyterhub exposes its port to the host and then remove the NGINX Docker container and install NGINX and certbot directly on the first host following [a standard setup](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04).

However, to keep the setup more modular, we'll proceed and use another NGINX container that comes equipped with automatic Let's Encrypt certificates request and renewal available at: <https://github.com/linuxserver/docker-letsencrypt>.

### Modify networking setup

One complication is that this container requires additional privileges to handle networking that are not availble in Swarm mode, so we will run this container outside of the Swarm on the first node.

We need to make the `jupyterhub` network that we created before attachable by containers outside the Swarm.

	docker service rm nginx
    bash remove_service_jupyterhub.sh
    docker network rm jupyterhub
    docker network create --driver overlay --attachable jupyterhub

Then add `--publish 8000` to `launch_service_juputerhub.sh` and start Jupyterhub again. Make sure that if you SSH to the first node you can `wget localhost:8000` successfully but if you try to access `yourdomain:8000` from the internet you **should not** be able to connect (the port should be closed by the networking configuration on OpenStack for example).

### Test the NGINX/Letsencrypt container

Create a volume to save the configuration and the logs (optionally on the NFS volume):

	docker volume create --driver local nginx_volume

Test the container running:

	docker run \
	  --cap-add=NET_ADMIN \
	  --name nginx \
	  -p 443:443 \
	  -e EMAIL=your_email@domain.edu \
	  -e URL=your.domain.org \
	  -v nginx_volume:/config \
	  linuxserver/letsencrypt

If this works correctly, connect to <https://your.domain.org>, you should have a valid SSL certificate and a welcome message. If not check `docker logs nginx`.

### Configure NGINX to proxy Jupyterhub

We can use `letsencrypt_container_nginx.conf` to handle NGINX configuration with HTTPS support, this loads the certificates from a path automatically created by the `letsencrypt` container.

Customize `launch_letsencrypt_container.sh` and then run it, it will create the NGINX container again and it will also bind-mount the NGINX configuration into the container.

Now you should be able to connect to your server over HTTPS and access Jupyterhub.

## Feedback

Feedback appreciated, [@andreazonca](https://twitter.com/andreazonca)

I am also available to support US scientists to deploy scientific gateways through the [XSEDE ECSS consulation program](https://www.xsede.org/for-users/ecss).
