Title: How to use the IPython notebook on a small computing cluster
Date: 2013-06-22 11:12
Author: Andrea Zonca
Tags: hpc, ipython
Slug: how-to-use-ipython-notebook-on-small

[The IPython notebook](http://ipython.org/ipython-doc/dev/interactive/htmlnotebook.html) is a powerful and easy to use interface for using Python and particularly useful when running remotely, because it allows the interface to run locally in your browser, while the computing kernel runs remotely on the cluster.

## 1) Configure IPython notebook:

First time you use the notebook you need to follow this configuration steps:

* Login to the cluster
* Load the python environment, for example:

        module load pythonEPD

* Create the profile files:

        ipython profile create # creates the configuration files
        vim .ipython/profile_default/ipython_notebook_config.py
  set a password, see instructions in the file.

* Change the port to something specific to you, **please change this to avoid conflict with other users**:
        
        c.NotebookApp.port = 8900

* Set a certificate to serve the notebook over https:

        c.NotebookApp.certfile = u'/home/zonca/mycert.pem'
  or create a new certificate, see [the documentation](http://ipython.org/ipython-doc/dev/interactive/htmlnotebook.html)

* Set:

        c.NotebookApp.open_browser = False

## 2) Run the notebook for testing on the login node.

You can use IPython notebook on the login node if you do not use much memory, e.g. &lt; 300MB.
ssh into the login node, at the terminal run:

    ipython notebook --pylab=inline

open the browser on your local machine and connect to (always use https, replace 8900 with your port):
  
    https://LOGINNODEURL:8900

Dismiss all the browser complaints about the certificate and go ahead.

## 3) Run the notebook on a computing node

You should always use a computing node whenever you need a large amount of resources.

Create a folder `notebooks/` in your home, just copy this script in `runipynb.pbs` in your that folder:

<script src="https://gist.github.com/zonca/5840518.js">
</script>
 
replace `LOGINNODEURL` with the url of the login node of your cluster.

NOTICE: you need to ask the sysadmin to set `GatewayPorts yes` in `sshd_config` on the login node to allow access externally to the notebook.

Submit the job to the queue running:

    qsub runipynb.pbs
 
Then from your local machine connect to (replace 8900 with your port):
   
    https://LOGINNODEURL:8900

##  Other introductory python resources

* [Scientific computing with Python](http://scipy-lectures.github.io/), large and detailed introduction to Python, Numpy, Matplotlib, Scipy
* My [Python for High performance computing](https://github.com/zonca/PythonHPC): slides and few ipython notebook examples, see the README
* My [short Python and healpy tutorial](https://github.com/zonca/healpytut/blob/master/healpytut.pdf?raw=true)
