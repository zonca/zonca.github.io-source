Title: IPython/Jupyter notebook setup on SDSC Comet
Date: 2015-09-17 20:00
Author: Andrea Zonca
Tags: ipython, jupyter, ipython-notebook
Slug: ipython-jupyter-notebook-sdsc-comet

## Introduction

This tutorial explains the setup to run an IPython Notebook on a computing node on the supercomputer Comet at the San Diego Supercomputer Center and forward the port encrypted with SSH to the browser on a local laptop.

## Quick reference

* Add `module load python scipy` to `.bashrc`
* Make sure you can ssh passwordless within comet, i.e. `ssh comet.sdsc.edu` from comet  login node works without password
* Get `submit_slurm_comet.sh` from <https://gist.github.com/zonca/5f8b5ccb826a774d3f89>
* Change the port number and customize options (duration)
* `sbatch submit_slurm_comet.sh`
* Remember the login node you are using
* From laptop, use `bash tunnel_notebook_comet.sh N` where N is the Comet login number (e.g. 2) from <https://gist.github.com/zonca/5f8b5ccb826a774d3f89>
* From laptop, open browser and connect to `http://localhost:YOURPORT`

## Detailed walkthrough

### One time setup on Comet

Login into a Comet login node, edit the `.bashrc` file in your home folder (with `nano .bashrc` for example) and add `module load python scipy` at the bottom. This makes sure you always have the Python environment loaded in all your jobs. Logout, log back in, make sure that `module list` shows `python` and `scipy`.

You need to be able to SSH from a node to another node on comet with no need of a password. Create a new SSH certificate with `ssh-keygen`, hit enter to keep all default options, DO NOT ENTER A PASSWORD. Then use `ssh-copy-id comet.sdsc.edu`, enter your password to make sure the key is copied in the authorized hosts.
Now you can check it works by executing:

    ssh comet.sdsc.edu
    
from the login node and make sure you are NOT asked for your password.

### Configure the script for SLURM and submit the job

Copy `submit_slurm_comet.sh` from <https://gist.github.com/zonca/5f8b5ccb826a774d3f89> on your home on Comet.

Change the port number in the script to a port of your choosing between 8000 and 9999, referenced as YOURPORT in the rest of the tutorial. Two users on the same login node on the same port would not be allowed to forward, so try to avoid common port numbers as 8000, 9000, 8080 or 8888.

Choose whether you prefer to use a full node to have access to all 24 cores and 128GB of RAM or if you only need 1 core and 5GB of RAM and change the top of the script accordingly.

Choose a duration of your job, for initial testing better keep 30 minutes so your job starts straight away.

Submit the job to the scheduler:

    sbatch submit_slurm_comet.sh
    
Wait for the job to start running, you should see `R` in:

    squeue -u $USER
    
The script launches an IPython notebook on a computing node and tunnels its port to the login node.

You can check that everything worked by checking that no errors show up in the `notebook.log` file, and that you can access the notebook page with `wget`:

    wget localhost:YOURPORT

should download a `index.html` file in the current folder, and NOT give an error like "Connection refused".

Check what login node you were using on comet, i.e. the hostname on your terminal on comet, for example `comet-ln2`.

### Tunnel the port to your laptop

#### Linux / MAC

Download the `tunnel_notebook_comet.sh` script from <https://gist.github.com/zonca/5f8b5ccb826a774d3f89>.

Customize the script with your port number.

Lauch `bash tunnel_notebook_comet.sh N` where N is the comet login node number. So if you were on `comet-ln2`, use `bash tunnel_notebook_comet.sh 2`.

The script forwards the port from the login node of comet to your laptop.

#### Windows

Install `putty`.

Follow tutorial for local port forwarding on <http://howto.ccs.neu.edu/howto/windows/ssh-port-tunneling-with-putty/>

* set `comet-ln2.sdsc.edu` as remote host, 22 as SSH port
* set YOURPORT as tunnel port, replace both 8080 and 80 in the tutorial with your port number. 

### Connect to the Notebook

Open a browser and type `http://localhost:YOURPORT` in the address bar.


