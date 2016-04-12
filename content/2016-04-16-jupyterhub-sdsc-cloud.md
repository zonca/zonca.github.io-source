Title: Deploy Jupyterhub on SDSC Cloud
Date: 2016-04-16 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub, sdsc
Slug: jupyterhub-sdsc-cloud

# Create a new Virtual Machine

* Login to the SDSC Cloud OpenStack dashboard
* Compute -> Access & Security -> Key Pairs -> Create key pair, name it `jupyterhub` and download it to your local machine
* Instances -> Launch Instance, Choose a name, Choose "Boot from image" in Boot Source and Ubuntu as Image name, Choose any size, depending on the number of users (TODO add link to Jupyterhub docs)
* Under "Access & Security" choose Key Pair `jupyterhub` and Security Groups `default`
* Click `Launch` to create the instance

# Setup Jupyterhub

