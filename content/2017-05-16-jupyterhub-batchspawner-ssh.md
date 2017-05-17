Title: Deploy Jupyterhub on a Supercomputer with SSH Authentication
Date: 2017-05-16 22:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, hpc, comet
Slug: jupyterhub-hpc-batchspawner-ssh

The best way to deploy Jupyterhub with an interface to a Supercomputer is through the use of `batchspawner`. I have a sample deployment explained in an older blog post: <https://zonca.github.io/2017/02/sample-deployment-jupyterhub-hpc.html>

This setup however requires a OAUTH service, in this case provided by XSEDE, to authenticate the users via web and then provide a X509 certificate that is then used by `batchspawner` to
connect to the Supercomputer on behalf of the user and submit the job to spawn a notebook.

In case an authentication service of this type is not available, another option is to use SSH authentication.

The starting point is a server with vanilla Jupyterhub installed, good practice would be to use an already available recipe with Ansible, like <https://zonca.github.io/2017/02/automated-deployment-jupyterhub-ansible.html>, that deploys Jupyterhub in a safer way, e.g. NGINX frontend with HTTPS.

First we want to setup authentication, the simpler way to start would be to use the default authentication with local UNIX user accounts and possibly add Github later.
In any case it is necessary that all the users have both an account on the Supercomputer and on the Jupyterhub server, with the same username, this is tedious but is the simpler way to allow them to authenticate on the Supercomputer.
Then we need to save the **private** SSH key into each user's `.ssh` folder and make sure they can SSH with no password required to the Supercomputer.

Then we can install `batchspawner` and configure Jupyterhub to use it. In the `batchspawner` configuration in `jupyterhub_config.py`, you have to prefix the scheduler commands with ssh so that Jupyterhub can connect to the Supercomputer to submit the job:

    c.SlurmSpawner.batch_submit_cmd = 'ssh {username}@{host} sbatch'
    
See for example [my configuration for Comet](https://github.com/jupyterhub/jupyterhub-deploy-hpc/blob/master/batchspawner-xsedeoauth-sshtunnel-sdsccomet/jupyterhub_config.py#L66) and replace `gsissh` with `ssh`.

Now when users connect, they are authenticated with local UNIX user accounts username and password and then Jupyterhub uses their SSH key to launch a job on the Supercomputer.

The last issue is how to proxy the Jupyterhub running on a computing node back to the server, here one option would be to create a user on the server with no Terminal access but with the possibility of creating tunnels, then at the end of the job, setup a tunnel using a SSH Private Key pasted into the job script itself, see for example [my setup on Comet](https://github.com/jupyterhub/jupyterhub-deploy-hpc/blob/master/batchspawner-xsedeoauth-sshtunnel-sdsccomet/jupyterhub_config.py#L54).

