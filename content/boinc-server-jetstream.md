Title: Install a BOINC server on Jetstream
Date: 2018-03-29 18:00
Author: Andrea Zonca
Tags: boinc, jetstream, gateways
Slug: boinc-server-jetstream

[BOINC](https://boinc.berkeley.edu/) is the leading platform for volunteer computing.

Scientists can create a project on the platform and submit computational jobs that will
be executed on computers of volunteers all over the world.

In this post we'll deploy a BOINC server on Jetstream. All US scientists can get a free
[allocation on Jetstream via XSEDE](https://jetstream-cloud.org/allocations.php).

The deployment will be based on the [Docker setup developed by the Cosmology@Home project](https://github.com/marius311/boinc-server-docker).

## Prepare a Jetstream Virtual Machine

First we login on the Atmosphere Jetstream control panel and create a new instance
of Ubuntu 16.04 with Docker preinstalled, a "small" size is enough for testing.

### (Optional) Mount a Jetstream Volume for docker images

It is ideal to have a dedicated Jetstream Volume and mount it in the location where
Docker stores its data. So we have more space, less usage of the root filesystem
and no issues on the OS if we get out of disk space.

We can create a volume of 10/20 GB in the Jetstream control panel and attach it to
the running Virtual Machine. This will be automatically mounted to `/vol_b`, we
want to mount instead to `/var/lib/docker`:

    sudo systemctl stop docker
    sudo mv /var/lib/docker/* /vol_b/
    sudo umount /vol_b

Replace `/vol_b` with `/var/lib/docker` in `/etc/fstab`, e.g.:

```
zonca@js-xxx-xxx:~$ cat /etc/fstab
LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
/dev/sdb /var/lib/docker ext4 defaults,nofail 0 2
```

Finally:

    sudo mount /var/lib/docker
    sudo systemctl start docker

### Update Docker

Docker in 16.04 is a bit old, we want to update it to a more recent version.

We also want to make sure to remove the old `docker` and `docker-compose`:

    sudo apt remove docker-compose docker

Then install a recent version,
we can follow the instructions from the docker website or use this script:

<https://gist.github.com/zonca/f5faba190f5285c68dad48e897622e90>

I adapted it from [kubeadm-bootstrap](https://github.com/data-8/kubeadm-bootstrap/blob/master/install-kubeadm.bash).

Finally install the latest `docker-compose`, see the [documentation](https://docs.docker.com/compose/install/#install-compose)

Last step, add your user to the `docker` group:

    sudo adduser $USER docker

logout and back in and make sure you can run `docker` commands without sudo:

    docker ps

### Install BOINC server via Docker

Follow the [instructions from `boinc-server-docker`](https://github.com/marius311/boinc-server-docker)
to launch a test deployment, in the last step, specify a `URL_BASE` so that
the deployment will be accessible from outside connections:

    URL_BASE=http://$(hostname) docker-compose up -d

You can check that the 3 containers are running with:

    docker ps

and inspect their logs with:

    docker logs <container_id>

After a few minutes you should be able to check that the server is running at the
public address of your instance:

<http://js-xxx-xxx.jetstream-cloud.org/boincserver/>

## (Optional) Mount Jetstream volumes on the containers

The Docker compose recipe defines 3 Docker volumes:

* `mysql`: Data of the MySQL database
* `project`: Files about the project
* `results`: Result of the BOINC jobs

those volumes are managed internally
by Docker and stored somewhere inside `/var/lib/docker` on the host node.


Docker also allows to mount specific folders from the host into a container,
if we back these folders by a Jetstream volume, we can have dedicated detachable Jetstream volumes
that live independently from any virtual machine.

Let's start by `mysql`, the same process can then be replicated for the other resources.

We create another Jetstream volume from the Atmosphere, name it `mysql` and attach it to the virtual machine,
this will be automatically mounted to `/vol_c`, we can rename it by:

    sudo umount /vol_c

Replace `vol_c` with `mysql` in `/etc/fstab`, finally:

    sudo mount /mysql

Finally you can modify the `docker-compose.yml` to use this folder instead of a Docker Volume:

In the `volumes:` section, remove `mysql:`, in the definition of the MySQL service,
replace:

    volumes:
     - "mysql:/var/lib/mysql"

with:

    volumes:
     - "/mysql:/var/lib/mysql"

So that instead of using a Docker Volume named `mysql` is creating a bind-mount to `/mysql` on the host.

## Test jobs

Open a terminal in the BOINC server container:

    docker exec -it <boincserver> /bin/bash


    bin/boinc2docker_create_work.py \
        python:alpine python -c "open('/root/shared/results/hello.txt','w').write('Hello BOINC')"

Then we can test a client connection and execution either with a standard BOINC desktop client or on another Jetstream instance.

### Test with a BOINC Desktop client

Follow the instructions on the [BOINC website](https://boinc.berkeley.edu/) to install a client for your OS, install also VirtualBox, then set as the URL of the BOINC server the URL of the server we just created.

### Test with a BOINC client in another Jetstream instance

Create another Ubuntu with Docker tiny instane on Jetstream, login,

    sudo adduser $USER docker

We need Virtualbox:
sudo apt install virtualbox-dkms

and reboot to make sure VirtualBox is active.

    URL=http://js-xxx-xxx.jetstream-cloud.org/boincserver/
    docker exec boinc boinccmd --create_account $URL email password name

    status: Success
    poll status: operation in progress
    poll status: operation in progress
    poll status: operation in progress
    account key: de9c4cc66b8c923d04f834a0609ae742

We can save the account key in a environment variable:

    URL=http://js-xxx-xxx.jetstream-cloud.org/boincserver/
    URL=http://js-xxx-xxx.jetstream-cloud.org/boincserver/
    account_key=de9c4cc66b8c923d04f834a0609ae742
    docker exec boinc boinccmd --project_attach $URL $account_key

Then we can check the logs for the job being received and executed:

    docker logs boinc

```
30-Mar-2018 13:02:04 [boincserver] Started download of layer_e9e858f6a2ba5a3e5a04b5799ef2de1c21a58602ffd400838ed10599f1b4a42c.tar.manual.gz
30-Mar-2018 13:02:06 [boincserver] Finished download of layer_10ffed26db733866a346caf7c79558e4addb23ae085a991b5e7237edaa69f8e2.tar.manual.gz
30-Mar-2018 13:02:06 [boincserver] Finished download of layer_e9e858f6a2ba5a3e5a04b5799ef2de1c21a58602ffd400838ed10599f1b4a42c.tar.manual.gz
30-Mar-2018 13:02:06 [boincserver] Started download of layer_0e650ab7661f993eff514b84c6e7b775f5be8c6dde8b63eb584f0f22ea24005f.tar.manual.gz
30-Mar-2018 13:02:06 [boincserver] Started download of image_4fcaf5fb5f2b8230c53b5fd4c4325df00021d45272dc4bfbb2148e5ca91ac166.tar.manual.gz
30-Mar-2018 13:02:07 [boincserver] Finished download of layer_0e650ab7661f993eff514b84c6e7b775f5be8c6dde8b63eb584f0f22ea24005f.tar.manual.gz
30-Mar-2018 13:02:07 [boincserver] Finished download of image_4fcaf5fb5f2b8230c53b5fd4c4325df00021d45272dc4bfbb2148e5ca91ac166.tar.manual.gz
30-Mar-2018 13:02:07 [boincserver] Starting task boinc2docker_3766_1522410497.503524_0
30-Mar-2018 13:02:07 [boincserver] Sending scheduler request: To fetch work.
30-Mar-2018 13:02:07 [boincserver] Requesting new tasks for CPU
30-Mar-2018 13:02:08 [boincserver] Scheduler request completed: got 1 new tasks
30-Mar-2018 13:02:12 [---] Vbox app stderr indicates CPU VM extensions disabled
30-Mar-2018 13:02:13 [boincserver] Computation for task boinc2docker_3766_1522410497.503524_0 finished
30-Mar-2018 13:02:13 [boincserver] Output file boinc2docker_3766_1522410497.503524_0_r207563194_0.tgz for task boinc2docker_3766_1522410497.503524_0 absent
30-Mar-2018 13:02:13 [boincserver] Starting task boinc2docker_3766_1522410497.503524_1
30-Mar-2018 13:02:18 [---] Vbox app stderr indicates CPU VM extensions disabled
30-Mar-2018 13:02:18 [boincserver] Computation for task boinc2docker_3766_1522410497.503524_1 finished
30-Mar-2018 13:02:18 [boincserver] Output file boinc2docker_3766_1522410497.503524_1_r1095010587_0.tgz for task boinc2docker_3766_1522410497.503524_1 absent
```
