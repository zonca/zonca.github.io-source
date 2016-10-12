Title: Jupyterhub Docker Spawner with GPU support
Date: 2016-10-12 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, cuda
Slug: dockerspawner-cuda

[Docker Spawner](https://github.com/jupyterhub/dockerspawner) allows users of Jupyterhub to run Jupyter Notebook inside isolated Docker Containers.
Access to the host NVIDIA GPU was not allowed until NVIDIA release the [NVIDIA-docker](https://github.com/NVIDIA/nvidia-docker) plugin.

## Build the Docker image

In order to make Jupyerhub work with NVIDIA-docker we need to build a Jupyterhub docker image for `dockerspawner` that includes both the `dockerspawner` `singleuser` or `systemuser` images and the `nvidia-docker` image.

The Jupyter `systemuser` images are built in several steps so let's use them as a starting point, it is good that both image start from Ubuntu 14.04.

* Download the `nvidia-docker` repository
* In `ubuntu-14.04/cuda/8.0/runtime/Dockerfile`, replace `FROM ubuntu:14.04` with `FROM jupyterhub/systemuser`
* Build this image `sudo docker build -t systemuser-cuda-runtime runtime`
* In `ubuntu-14.04/cuda/8.0/devel/Dockerfile`, replace `FROM cuda:8.0-runtime` with `FROM systemuser-cuda-runtime`
* Build this image `sudo docker build -t systemuser-cuda-devel devel`

Now we have 2 images, either just CUDA 8.0 runtime or also the compiler `nvcc` and other development tools.

Make sure the image itself runs from the command line on the host:

    sudo nvidia-docker run --rm systemuser-cuda-devel nvidia-smi 

## Configure Jupyterhub

In `jupyterhub_config.py`, first of all set the right image:

    c.DockerSpawner.container_image = "systemuser-cuda-devel"
    
However this is not enough, `nvidia-docker` images need special flags to work properly and mount the host GPU into the containers, this is usually performed calling `nvidia-docker` instead of `docker` from the command line.
In `dockerspawner` however, we are directly using the docker library, so we need to properly configure the environment there.

First of all, we can get the correct flags by calling from the host machine:

    curl -s localhost:3476/docker/cli

The result for my machine is:

    --volume-driver=nvidia-docker --volume=nvidia_driver_361.93.02:/usr/local/nvidia:ro --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidia0 --device=/dev/nvidia1
    
Now we can configure `dockerspawner` using those values, in my case:

```
c.DockerSpawner.read_only_volumes = {"nvidia_driver_361.93.02":"/usr/local/nvidia"}
c.DockerSpawner.extra_create_kwargs = {"volume_driver":"nvidia-docker"}
c.DockerSpawner.extra_host_config = { "devices":["/dev/nvidiactl","/dev/nvidia-uvm","/dev/nvidia-uvm-tools","/dev/nvidia0","/dev/nvidia1"] }
```

## Test it

Login with Jupyterhub, try this notebook: <http://nbviewer.jupyter.org/gist/zonca/a14af3b92ab472580f7b97b721a2251e>

## Current issues

* Environment on the Jupyterhub kernel is missing `LD_LIBRARY_PATH`, running directly on the image instead is fine
* I'd like to test using `numba` in Jupyterhub, but that requires `cudatoolkit` 8.0 which is not available yet in Anaconda
