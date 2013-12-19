Title: Run IPython Notebook on a HPC Cluster via PBS
Date: 2013-12-18 16:30
Author: Andrea Zonca
Tags: ipython, ipython-notebook, HPC
slug: run-ipython-notebook-on-HPC-cluster-via-PBS

The [IPython notebook](http://ipython.org/notebook.html) is a great tool for data exploration
and visualization.
It is suitable in particular for analyzing a large amount of data remotely on a computing node
of a HPC cluster and visualize it in a browser that runs on a local machine.
In this configuration, the interface is local, it is very responsive, but the amount of memory
and CPU horsepower is provided by a HPC computing node.

Also, it is possible to keep the notebook server running, disconnect and reconnect later from
another machine to the same session.

I created a script which is very general and can be used on most HPC cluster and published it on Github:

[https://github.com/zonca/ipynbhpc](https://github.com/zonca/ipynbhpc)

Once the script is running, it is possible to connect to `localhost:PORT` and visualize the 
IPython notebook, see the following screenshot of Chromium running locally on my machine
connected to a IPython notebook running on a Gordon computing node:

{% img /images/run-ipython-notebook-on-HPC-cluster-via-PBS_screenshot.png 730 IPython notebook on Gordon %}
