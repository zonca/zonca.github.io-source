Title: Use your own Python installation (kernel) in Jupyterhub
Date: 2015-10-05 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub
Slug: use-own-python-in-jupyterhub

You have access to a Jupyterhub server but the Python installation provided does not satisfy your needs,
how to use your own?

## Install Anaconda

If you haven't already your own Python installation on the Jupyterhub server you have access to, you can install Anaconda in your home folder. I assume here you have a permanent home folder on the server.

In order to type commands, you can either
get a Jupyterhub Terminal, or run in the IPython notebook with `!`.

* `!wget https://repo.continuum.io/archive/Anaconda3-2.3.0-Linux-x86_64.sh`
* `!bash ./Anacon*`

## Create a kernel file for Jupyterhub

You probably already know you can have Python 2 and Python 3 kernels on the same Jupyter notebook installation. In the same way you can create your own `KernelSpec` that launches instead another Python installation.

IPython can automatically create a `KernelSpec` for you, from the IPython notebook, run:

	!~/anaconda3/bin/ipython kernelspec install-self --user

In case your path is different, just insert the full path to `ipython` from the Python installation you would like to use.

This will create a file `kernel.json` in `~/.ipython/kernels/python3`, you can open that file with an editor and change the `display_name` to something better than the default `Python 3`, like `My Anaconda`.

## Launch a Notebook

Go back to the Jupyterhub dashboard, reload the page, now you should have another option in the `New` menu that says `My Anaconda`.

In order to use your new kernel with an existing notebook, click on the notebook file in the dashboard, it will launch with the default kernel, then you can change kernel from the top menu `Kernel` > `Change kernel`.
