Title: Customize your Python environment in Jupyterhub
Date: 2017-02-24 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub
Slug: customize-python-environment-jupyterhub

Usecase: You have access to a Jupyterhub server and you would like to install some packages but cannot use `pip install` and modify the systemwide Python installation.

## Check if conda is available

First check if the Python installation you have access to is based on Anaconda, open a Notebook and type:

	!which conda

`!` executes bash commands instead of Python commands, we want to check if the `conda` package manager is installed.

If not, the setup is a bit tedious, so see my tutorial on [installing Anaconda in your home folder](https://zonca.github.io/2015/10/use-own-python-in-jupyterhub.html)

## Create a conda environment

Conda allows to create independent environments in our home folder, this has the advantage that the environment will be writable so we can install any other package with `pip` or `conda install`.

	!conda create -n myownenv --clone root

You can declare all the packages you want to install bu good starting point is just to clone the `root` environment, this will link all the global packages in your home folder, then you can customize it further.

## Create a Jupyter Notebook kernel to launch this new environment

We need to notify Jupyter of this new Python environment by creating a Kernel, from a Notebook launch:

	!source activate myownenv; ipython kernel install --user --name myownenv

## Launch a Notebook

Go back to the Jupyterhub dashboard, reload the page, now you should have another option in the `New` menu that says `myownenv`.

In order to use your new kernel with an existing notebook, click on the notebook file in the dashboard, it will launch with the default kernel, then you can change kernel from the top menu `Kernel` > `Change kernel`.

## Install new packages

Inside a Notebook using the `myownenv` environment you can install other packages running:

	!conda install newpackagename

or:

	!pip install newpackagename
