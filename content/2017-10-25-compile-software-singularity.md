Title: How to modify Singularity images on a Supercomputer
Date: 2017-11-06 18:00
Author: Andrea Zonca
Tags: singularity, hpc, Comet
Slug: modify-singularity-images

## Introduction

[Singularity](http://singularity.lbl.gov/) allows to run your own OS within most Supercomputers, see my previous post about [Running Ubuntu on Comet via Singularity](https://zonca.github.io/2017/01/singularity-hpc-comet.html)

Singularity's adoption by High Performance Computing centers has been driven by its strict security model. It never allows a user in a container to have `root` privileges unless the user is `root` on the Host system.

This means that you can only modify containers on a machine where you have `root`. Therefore you generally build a container on your local machine and then copy it to a Supercomputer.
The process is tedious if you are still tweaking your container and modifying it often, and each time your have to copy back a 4 or maybe 8 GB container image.

In the next section I'll investigate possible solutions/workarounds.

## Use DockerHub

Singularity can pull a container from DockerHub, so it is convenient if you are already using Docker, maybe to provide a simple way to install your software.

I found out that if you are using the Automatic build of your container by DockerHub itself, this is very slow, sometimes it takes 30 minutes to have your new container build.

Therefore the best is to manually build your container locally and then push it to DockerHub. A Docker container is organized in layers of the filesystem, so for small tweaks to your image you transfer tens of MB to DockerHub instead of GB.

Then from the Supercomputer you can run `singularity pull docker://ubuntu:latest` with no need of `root` privileges. Singularity keeps a cache of the docker layers, so you would download just the layers modified in the previous step.

## Build your application locally

If you are modifying an application often you could build a Singularity container with all the requirements, copy it to the Supercomputer and then build your application there. This is also useful if the architecture of your CPU is different between your local machine and the Supercomputer and you are worried the compiler would not apply all the possible optimizations.

In this case you can use `singularity shell` to get a terminal inside the container, then build your software with the compiler toolchain available **inside the container** and then install it to your `$HOME` folder, then modify your `$PATH` and `$LD_LIBRARY_PATH` to execute and load libraries from this local folder.

This is also useful in case the container has already an application installed but you want to develop on it. You can follow this process and then mask the installed application with your new version.

Of course this makes your analysis **not portable**, the software is not available inside the container.

### Freeze your application inside the container

Once you have completed tweaking the application on the Supercomputer, you can now switch back to your local machine, get the last version of your application and install it system-wide inside the container so that it will be portable.

On the other hand, you might be concerned about performance and prefer to have the application built on the Supercomputer. You can run the build process (e.g. `make` or `python setup.py build) on the Supercomputer in your home, then sync the build artifacts back to your local machine and run the install process there (e.g `sudo make install` or `sudo python setup.py install`). Optionally use `sshfs` to mount the build folder on both machines and make the process transparent.

## Use a local Singularity registry

Singularity released [`singularity-registry`](https://singularityhub.github.io/singularity-registry/inst/), an application to build a local image registry, like DockerHub, that can take care of building containers.

This can be hosted locally at a Supercomputing Center to provide a local building service. For example Texas Advanced Computing Center [builds locally Singularity images from BioContainers](https://www.slideshare.net/JohnFonner1/biocontainers-for-supercomputers-2000-accessible-discoverable-singularity-apps), software packages for the Life Sciences.

Otherwise, for example,  a user at SDSC could install Singularity Registry on SDSC Cloud and configure it to mount one of Comet's filesystems and build the container images there. Even installing Singularity Registry on Jetstream could be an option thanks to its fast connection to other XSEDE resources.


## Feedback

If you have any feedback, please reach me at [@andreazonca](https://twitter.com/andreazonca) or find my email from there.
