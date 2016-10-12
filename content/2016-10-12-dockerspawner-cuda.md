Title: Jupyterhub Docker Spawner with CUDA access
Date: 2016-10-12 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, cuda
Slug: jupyterhub-docker-swarm

[Docker Spawner](https://github.com/jupyterhub/dockerspawner) allows users of Jupyterhub to run Jupyter Notebook inside isolated Docker Containers.
Access to the host NVIDIA GPU was not allowed until NVIDIA release the [NVIDIA-docker](https://github.com/NVIDIA/nvidia-docker) plugin.

In order to make Jupyerhub work with NVIDIA-docker we need to build a Jupyterhub docker image for `dockerspawner` that includes both the `dockerspawner` `singleuser` or `systemuser` images and the `nvidia-docker` image.

