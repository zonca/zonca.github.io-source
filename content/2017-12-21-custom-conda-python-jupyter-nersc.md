Title: Install custom Python environment on Jupyter Notebooks at NERSC
Date: 2017-12-21 18:00
Author: Andrea Zonca
Tags: jupyterhub, python, nersc
Slug: custom-conda-python-jupyter-nersc

## Jupyter Notebooks at NERSC

NERSC has provided a JupyterHub instance for quite some time to all NERSC users.
It is currently running on a dedicated large-memory node on Cori, so now it can access also data on
Cori `$SCRATCH`, not only `/project` and `$HOME`. See [their documentation](http://www.nersc.gov/users/data-analytics/data-analytics-2/jupyter-and-rstudio/)

## Customize your Python environment

NERSC provides Anaconda in a Ubuntu container, of course the user doesn't have permission to write to the Anaconda folder to install new packages.

The easiest way is to install a custom Python environment is to create another conda environment and then register the Kernel with Jupyter.

Create a new conda environment, best choice is `/project` if you have one, otherwise `$HOME` would work.
Access <http://jupyter.nersc.gov>, open a terminal with "New"->"Terminal".

    conda create --prefix $HOME/myconda python=3.6 ipykernel

This is the minimal requirement, you could just add `anaconda` to get all the latest packages, you can also specify `conda-forge` to install other packages, e.g.:

    source activate myconda
    conda install -c conda-forge healpy

Register the kernel with the Jupyter Notebook:

    ipython kernel install --name myconda --user

The name of the kernel specified here doesn't need to be the same as the conda environment name, but it is simpler.

Once the conda environment is active, you can also install packages with `pip`.

    conda install pip
    pip install somepackage
