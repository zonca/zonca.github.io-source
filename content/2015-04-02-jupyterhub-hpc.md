Title: Run Jupyterhub on a Supercomputer
Date: 2015-04-02 9:00
Author: Andrea Zonca
Tags: python, ipython, jupyterhub, hpc
Slug: jupyterhub-hpc

The IPython (recently renamed Jupyter) Notebook is a powerful tool for analyzing and visualizing data in Python and other programming languages.
A key feature is that a single document contains code, figures, text and equations.
Everything is saved in a single .ipynb file that can be shared, executed and modified. See an [example Notebook on integration of partial differential equations](http://nbviewer.ipython.org/github/waltherg/notebooks/blob/master/2013-12-03-Crank_Nicolson.ipynb "example notebook").

The Jupyter Notebook is a Python application with a web frontend, i.e. the interface runs in the user browser.
This setup makes it suitable for any kind of remote computing, in particular running the Jupyter Notebook on a computing node of a Supercomputer, and exporting the interface HTTP port to a local browser.
Setting up tunneling via SSH is tedious, in particular if the user does not have a public IP address.

[Jupyterhub](https://github.com/jupyter/jupyterhub "jupyterhub"), developed by the Jupyter team, comes to the rescue by providing a web application that manages and proxies multiple instances of the Jupyter Notebook for any number of users.
Jupyterhub natively only spawns local processes, but supports plugins to extend its functionality.

I have been developing a proof-of-concept plugin ([RemoteSpawner](https://github.com/zonca/remotespawner)) designed to work on a web server and once a user is authenticated, connect to the login node of a Supercomputer and submit a Jupyter Notebook job.
As soon as the job starts execution, it sets up SSH tunneling with the Jupyterhub host so that
Jupyterhub can provide the Notebook interface to the user.
This setup allows users to simply access a Supercomputer via browser, accessing all their Python environment and data.

## Tour of Jupyterhub on the Gordon Supercomputer

I'll show some screenshots to display how a test Jupyterhub installation on my machine is integrated with [Gordon](http://www.sdsc.edu/us/resources/gordon/) thanks to the plugin.

Jupyterhub is accessed publicly via browser and the user can login. Jupyterhub supports authentication for `PAM`/`LDAP` so it could be integrated with XSEDE credential, at the moment I am testing with local authentication.

![jupyterhub-hpc-login.png](/content/jupyterhub-hpc-login.png)

I am looking for interested parties either as users or as collaborators to help further development.
