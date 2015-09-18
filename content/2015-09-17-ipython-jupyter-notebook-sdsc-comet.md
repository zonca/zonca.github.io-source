Title: IPython/Jupyter notebook setup on SDSC Comet
Date: 2015-09-17 20:00
Author: Andrea Zonca
Tags: ipython, jupyter, ipython-notebook
Slug: ipython-jupyter-notebook-sdsc-comet

## Quick reference

* Add `module load python scipy` to `.bashrc`
* Make sure you can ssh passwordless within comet, i.e. `ssh comet.sdsc.edu` from comet  login node works without password
* Get `submit_slurm_comet.sh` from https://gist.github.com/zonca/5f8b5ccb826a774d3f89
* Change the port number and customize options (duration)
* `sbatch submit_slurm_comet.sh`
* Remember the login node you are using
* From laptop, use `tunnel_notebook_comet.sh` from https://gist.github.com/zonca/5f8b5ccb826a774d3f89

## Detailed walkthrough

### One time setup on Comet

Login to a comet login node, edit the `.bashrc` file in your home folder (with `nano .bashrc` for example) and add `module load python scipy` at the bottom. This makes sure you always have the Python environment loaded in all your jobs.

You need to be able to ssh from a node to another node on comet with no need of a password. Create a new SSH certificate with `ssh-keygen`, hit enter to keep all default options, DO NOT ENTER A PASSWORD. Then use `ssh-copy-id comet.sdsc.edu`, enter your password to make sure the key is copied in the authorized hosts.
Now you can check it works by executing:

    ssh comet.sdsc.edu
    
from the login node and make sure you are NOT asked for your password.

### Configure the script for SLURM

Copy `submit_slurm_comet.sh` from https://gist.github.com/zonca/5f8b5ccb826a774d3f89 on your home on Comet.

Change the port number in the script to a port of your choosing between 10000 and 23000.

Choose whether you prefer to use a full node to have access to all 24 cores and 128GB of RAM or if you only need 1 core and 5 GB of RAM and change the top of the script accordingly.

Choose a duration of your job, for initial testing better keep 30 minutes so your job starts straight away.

Submit the job to the scheduler:

    sbatch submit_slurm_comet.sh
    
Wait for the job to start running, you should see `R` in:

     squeue -u $USER
     
The script launches an IPython notebook on a computing node and tunnels its port to the login node.

Check that the 
