Title: Python on Gordon
Date: 2014-02-13 14:30
Author: Andrea Zonca
Tags: hpc, python, Gordon
Slug: Setup-Python-IPython-notebook-parallel-Gordon
Status: draft

Gordon has already a `python` environment setup which can be activated by loading the `python` module:

    module load python # add this to .bashrc to load it at every login

### Install virtualenv

Then we need to setup a sandboxed local environment to install other packages, by using `virtualenv`, get the link to the latest version from https://pypi.python.org/pypi/virtualenv, then download it on gordon and unpack it, e.g.

    wget --no-check-certificate https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.11.2.tar.gz#md5=d3d915836c1ada1be731ccaa12412b98
    tar xzvf virtualenv*tar.gz

Then create your own virtualenv and load it:

	mkdir ~/venv
    python virtualenv-1.11.2/virtualenv.py ~/venv/py
    source ~/venv/py/bin/activate # add this to .bashrc to load it at every login

you can restore your previous environment by deactivating the virtualenv:

	deactivate # from your bash prompt
    
### Install IPython

Using `pip` you can install `IPython` and all dependencies for the notebook and parallel tools running:

    pip install ipython pyzmq tornado jinja

### Configure the IPython notebook
For interactive data exploration, you can run the `IPython` notebook in a computing node on Gordon and export the web interface to your local machine, which also embeds all the plots.
Configuring the tunnelling over SSH is complicated, so I created a script, takes a little time to setup but then is very easy to use, see https://github.com/pyHPC/ipynbhpc.

### Configure IPython parallel
[IPython parallel](http://ipython.org/ipython-doc/stable/parallel/) on Gordon allows to 
First of all create the default configuration files:

    ipython profile create --parallel 
Then, in `~/.ipython/profile_default/ipcluster_config.py`, you need to setup:

    c.IPClusterStart.controller_launcher_class = 'LocalControllerLauncher' 
    c.IPClusterStart.engine_launcher_class = 'PBS' 
    c.PBSLauncher.batch_template_file = u'/home/REPLACEWITHYOURUSER/.ipython/profile_default/pbs.engine.template' # ~ does not work
    
You also need to allow connections to the controller from other hosts, setting  in `~/.ipython/profile_default/ipcontroller_config.py`: 

    c.HubFactory.ip = '*'
    c.HubFactory.engine_ip = '*'

Finally create the PBS template `~/.ipython/profile_default/pbs.engine.template`:

    #!/bin/bash
    #PBS -q normal
    #PBS -N ipcluster
    #PBS -l nodes={n/16}:ppn=n:native
    #PBS -l walltime=01:00:00
    #PBS -o ipcluster.out
    #PBS -e ipcluster.err
    #PBS -m abe
    #PBS -V
    mpirun_rsh -np {n} -hostfile $PBS_NODEFILE ipengine

Here we chose to run 16 IPython engines per Gordon node, so each has access to 4GB of ram, if you need more just change 16 to 8 for example.

### Run IPython parallel

You can submit a job to the queue running, `n` is equal to the number of processes you want to use, so it needs to be a multiple of the `ppn` chosen in the PBS template:

    ipcluster --n=32 &
   
in this case we are requesting 2 nodes, with 16 IPython engines each, check with:

    qstat -u $USER
   
basically `ipcluster` runs an `ipcontroller` on the login node and submits a job to PBS for running the `ipengines` on the computing nodes.

### Submit jobs to IPython parallel

Once the the `ipcluster` is running (no need to wait for the PBS job to 

