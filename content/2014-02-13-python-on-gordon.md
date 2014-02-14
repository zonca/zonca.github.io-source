Title: Python on Gordon
Date: 2014-02-13 14:30
Author: Andrea Zonca
Tags: hpc, python, Gordon
Slug: setup-ipython-notebook-parallel-Gordon
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

    ipcluster start --n=32 &
   
in this case we are requesting 2 nodes, with 16 IPython engines each, check with:

    qstat -u $USER
   
basically `ipcluster` runs an `ipcontroller` on the login node and submits a job to PBS for running the `ipengines` on the computing nodes.

Once the PBS job is running, check that the engines are connected by opening a IPython on the login node and print the `ids`:

    In [1]: from IPython.parallel import Client
    In [2]: rc = Client()
    In [3]: rc.ids

You can stop the cluster (kill `ipcontroller` and `qdel` the PBS job) either by sending CTRL-c to `ipcluster` or running:

    ipcluster stop
    
### Submit jobs to IPython parallel

As soon as `ipcluster` is executed, `ipcontroller` is ready to queue jobs up, which will be then consumed by the engines once they will be running.
The easiest method to submit jobs with automatic load balancing is to create a load balanced view:

    In [1]: from IPython.parallel import Client
    In [2]: rc = Client()
    In [3]: lview = rc.load_balanced_view() # default load-balanced view

and then use its `map` method:
    
    def exp_10(x):
    	return x**10
        
    list_of_args = range(100)
    result = lview.map(exp_10, list_of_args)

In this code `IPython` will distribute uniformly the list of arguments to the engines and the function will be evalutated for each of them and the result copied back to the connecting client running on the login node.

### Submit non-python jobs to IPython parallel
Let's assume you have a list of commands you want to run in a text file, one command per line, those could be implemented in any programming language, e.g.:

    date &> date.log
    hostname &> hostname.log
 
Then you create a function that executes one of those commands:

	def run_command(command):
        import subprocess
        subprocess.Popen(command, shell = True)
   
Then apply this function to the list of commands:

    list_of_commands = open("commands.txt").readlines()
    lview.map(run_command, list_of_commands)

I created a script that automates this process, see https://gist.github.com/zonca/8994544, you can run as:

    ./ipcluster_run_commands.py commands.txt

