Title: Sample deployment of Jupyterhub in HPC on SDSC Comet
Date: 2017-02-26 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, hpc, comet
Slug: sample-deployment-jupyterhub-hpc

I have deployed an experimental Jupyterhub service (ask me privately if you would like access) installed on a [SDSC Cloud](http://www.sdsc.edu/services/it/cloud.html) virtual machine that spawns single user Jupyter notebooks on Comet computing nodes using [`batchspawner`](https://github.com/jupyterhub/batchspawner) and then proxies the Notebook back to the user using SSH-tunneling.

## Functionality

This kind of setup is functionally equivalent to launching a job yourself on Comet, launch `jupyter notebook` and then SSH-Tunneling the port to your local machine, but way more convenient. You jus open your browser to  the Jupyterhub instance, authenticate with your XSEDE credentials, choose queue and job length and wait for the Notebook job to be ready (generally it is a matter of minutes).

## Rationale

Jupyter Notebooks have a lot of use-cases on HPC, it can be used for:

* In-situ visualization
* Interactive data analysis when local resources are not enough, either in terms of RAM or disk space
* Monitoring other running jobs

More on this on my [Run Jupyterhub on a Supercomputer](https://zonca.github.io/2015/04/jupyterhub-hpc.html) old blog post.

## Setup details

The Jupyter team created a repository for sample HPC deployments, I added all configuration files of my deployment there, with all details about the setup:

* [Sample deployment in the `jupyterhub-deploy-hpc` repository](https://github.com/jupyterhub/jupyterhub-deploy-hpc/tree/master/batchspawner-xsedeoauth-sshtunnel-sdsccomet)

Please send feedback opening an issue in that repository and tagging `@zonca`.
