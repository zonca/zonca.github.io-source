Title: PEARC18 Paper on Deploying Jupyterhub at scale on XSEDE
Date: 2018-07-23 12:00
Author: Andrea Zonca
Tags: singularity, comet, jetstream, jupyterhub
Slug: pearc18-paper-deploy-jupyterhub-xsede

Bob Sinkovits and I are presenting a paper at PEARC18 about:

"Deploying Jupyter Notebooks at scale on XSEDE resources for Science Gateways and workshops"

See the pre-print on Arxiv: <https://arxiv.org/abs/1805.04781>

Jupyter Notebooks provide an interactive computing environment well suited for Science.
JupyterHub is a multi-user Notebook environment developed by the Jupyter team.

In order to provide adequate amount of memory and CPU to many users for example during workshops,
it is necessary to leverage a distributed system, either leveraging multiple Jetstream instances
or interfacing with a traditional HPC system.

In this work we present 3 strategies for deploying JupyterHub on XSEDE resources to support
a large number of users, each is linked to the step-by-step tutorial with all necessary configuration files:

* [deploy Jupyterhub on a single Jetstream instance and spawn Jupyter Notebook servers for each user on a computing node of a Supercomputer (for example Comet)](https://zonca.github.io/2017/05/jupyterhub-hpc-batchspawner-ssh.html)
* [deploy Jupyterhub on Jetstream using Docker Swarm to distributed the user's containers across many instances and providing persistent storage with quotas through a NFS share](https://zonca.github.io/2017/10/scalable-jupyterhub-docker-swarm-mode.html)
* [deploy Jupyterhub on top of Kubernetes across Jetstream instances with persistent storage provided by the Ceph distributed filesystem](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html)

[Presentation slides](https://zonca.github.io/docs/pearc18_slides_zonca_sinkovits.pdf)

If are an author at PEARC18, you can follow [my instructions on how to publish your preprint to Arxiv](https://zonca.github.io/2018/05/pearc18-preprint-arxiv.html)
