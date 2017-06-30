Title: How to create pull requests on Github
Date: 2017-06-30 11:00
Author: Andrea Zonca
Tags: git, github
Slug: quick-github-pull-requests

Pull Requests are the web-based version of sending software patches via email to code maintainers.
They allow athat has no access to a code repository to submit a code change to the repository administrator that can review and mr
I cannot find a guide to making pull requests on Github with the 
Last year I wrote some tutorials on simple deployments of Jupyterhub on Ubuntu 16.04 on the OpenStack deployment [SDSC Cloud](http://www.sdsc.edu/services/it/cloud.html), even if most of the steps would also be suitable on other resources like Amazon EC2.

In more detail:

* [Manually installing Jupyterhub on a single Virtual Machine with users running inside Docker containers](https://zonca.github.io/2016/04/jupyterhub-sdsc-cloud.html)
* [Quick deployment of the above using a pre-built image](https://zonca.github.io/2016/04/jupyterhub-image-sdsc-cloud.html)
* [Jupyterhub distributing user containers on other nodes using Docker Swarm](https://zonca.github.io/2016/05/jupyterhub-docker-swarm.html)

The Jupyter team has released an automated script to deploy Jupyterhub on a single server, see [Jupyterhub-deploy-teaching](http://jupyterhub-deploy-teaching.readthedocs.io).

In this tutorial we will use this script to deploy Jupyterhub to SDSC Cloud using:

* NGINX handling HTTPS with Letsencrypt certificate
* Github authentication
* Local or Docker user notebooks
* Grading with `nbgrader`
* Memory limit for Docker containers

## Setup a Virtual Machine to run Jupyterhub

Create first a Ubuntu 16.04 Virtual Machine, a default server image works fine.

In case you are deploying on SDSC Cloud, follow the steps in "Create a Virtual Machine in OpenStack" on my first tutorial at <https://zonca.github.io/2016/04/jupyterhub-sdsc-cloud.html>.

You will also need a DNS entry pointing to the server to create a SSL certificate with Let's Encrypt. Either ask your institution to provide a DNS A entry, e.g. `test-jupyterhub.ucsd.edu`, that points to the Public IP of the server.
SDSC Cloud already provides a DNS entry in the form `xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu`.

If you plan on using `nbgrader`, you need to create the home folder for the instructor beforehand, so SSH into the server and create a user with your Github username, i.e. I had to execute `sudo adduser zonca`

## Setup your local machine to run the automation scripts

Automation of the server setup is provided by the [Ansible](http://ansible.com) software tool, it allows to describe a server configuration in great detail (a "playbook") and then connects via SSH to a Virtual Machine and runs Python to install and setup all the required software.

On your local machine, install `Ansible`, at least version 2.1, see [Ansible docs](http://docs.ansible.com/ansible/intro_installation.html#getting-ansible), for Ubuntu just add the [Ansible PPA repository](https://launchpad.net/~ansible/+archive/ubuntu/ansible).
I tested this with Ansible version 2.2.1.0

Then you need to configure passwordless SSH connection to your Virtual Machine. Download your SSH key from the OpenStack dashboard, copy it to your `~/.ssh` folder and then add an entry to `.ssh/config` for the server:

	Host xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu
		HostName xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu
		User ubuntu
		IdentityFile "~/.ssh/sdsccloud.key"

At this point you should be able to SSH into the machine without typing any password with `ssh xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu`.

## Configure and run the Ansible script

Follow the [Jupyterhub-deploy-teaching documentation](http://jupyterhub-deploy-teaching.readthedocs.io/en/latest/installation.html) to checkout the script, configure and run it.

The only modification you need to do if you are on SDSC Cloud is that the remote user is `ubuntu` and not `root`, so modify `ansible.cfg` in the root of the repository,
replace `remote_user=root` with `remote_user=ubuntu`.

As an example, see the [configuration I used](https://gist.github.com/zonca/fd2400a2069b5769f32b1c4b57eb97dc), just:

* copy it into `host_vars`
* rename it to your public DNS record
* fill in `proxy_auth_token`, Github OAuth credentials for authentication
* replace `zonca` with your Github username everywhere

The exact version of the `jupyterhub-deploy-teaching` code I used for testing is [on the `sdsc_cloud_jan_17` tag on Github](https://github.com/zonca/jupyterhub-deploy-teaching/releases/tag/sdsc_cloud_jan_17)

## Test the deployment

Connect to <https://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu> on your browser, you should be redirected to Github for authentication and then access a Jupyter Notebook instance with the Python 3, R and bash kernels running locally on the machine.

## Optional: Docker

In order to provide isolation and resource limits to the users, it is useful to run single user Jupyter Notebooks inside Docker containers.

You will need to SSH into the Virtual Machine and follow the next steps.

### Install Docker

First of all we need to install and configure Docker on the machine, see:

* <https://docs.docker.com/engine/installation/linux/ubuntu/>
* <https://docs.docker.com/engine/installation/linux/linux-postinstall/>

### Install dockerspawner

Then install the Jupyterhub plugin `dockerspawner` that handles launching single user Notebooks inside Docker containers, we want to install from master instead of pypi to avoid an error setting the memory limit.

	pip install git+https://github.com/jupyterhub/dockerspawner

### Setup the Docker container to run user Notebooks

We can first get the standard `systemuser` container, this Docker container mounts the home folder of the users inside the container, this way we can have persistent data even if the container gets deleted.

    docker pull jupyterhub/systemuser

If you do not need [`nbgrader`](http://nbgrader.readthedocs.io) this image is enough, otherwise we have to build our own image, first checkout my Github repository in the home folder of the `ubuntu` user on the server with:

	git clone https://github.com/zonca/systemuser-nbgrader

then edit the `nbgrader_config.py` file to set the correct `course_id`, and build the container image running inside the `systemuser-nbgrader` folder:

	docker build -t systemuser-nbgrader .

### Configure Jupyterhub to use dockerspawner

Then add some configuration for dockerspawner to `/etc/jupyterhub/jupyterhub_config.py`:

	c.JupyterHub.spawner_class = 'dockerspawner.SystemUserSpawner'
	c.DockerSpawner.container_image = "systemuser-nbgrader" # delete this line if you just need `jupyterhub/systemuser`
																											  c.Spawner.mem_limit = '500M' # or 1G for GB, probably 300M is minimum required just to run simple calculations
	c.DockerSpawner.volumes = {"/srv/nbgrader/exchange":"/tmp/exchange"} # this is necessary for nbgrader to transfer homework back and forth between students and instructor
	c.DockerSpawner.remove_containers = True

	# The docker instances need access to the Hub, so the default loopback port doesn't work:
	from IPython.utils.localinterfaces import public_ips
	c.JupyterHub.hub_ip = public_ips()[0]

### Test the deployment with Docker

Connect to <https://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu> on your browser, you should be redirected to Github for authentication and then access a Jupyter Notebook instance with the Python 2 or Python 3, open a Notebook and run `!hostname` in the first cell, you should find out that you get a Docker hash instead of the machine name, you are inside a container.

SSH into the machine run `docker ps` to find the hash of a running container and then `docker stat HASH` to check memory usage and the current limit.

Check that you can connect to the `nbgrader` `formgrade` service that allows to manually grade assignments at <https://xxx-xxx-xxx-xxx.compute.cloud.sdsc.edu/services/formgrade-COURSEID>, replace `COURSEID` with the course identifier you setup in the Ansible script.

### Pre-built image

I also have a saved Virtual Machine snapshot on SDSC Cloud named `jupyterhub_ansible_nbgrader_coleman`
