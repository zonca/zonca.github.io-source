Title: How to organize code and data for simulations at NERSC
Date: 2018-06-20 18:00
Author: Andrea Zonca
Tags: nersc, python
Slug: organize-code-data-simulations-nersc

I recently improved my strategy for organizing code and data for simulations run at NERSC,
I'll write it here for reference.

## Libraries

I mostly use Python (often with C/C++ extensions), so I first rely on the Anaconda
module maintained by NERSC, currently `python/3.6-anaconda-4.4`.

If I need to add many more packages I can create a conda environment, but for just installing
1 or 2 packages I prefer to just add them to my `PYTHONPATH`.

I have core libraries that I rely on and often modify to run my simulations,
those should be installed on Global Common Software: `/global/common/software/projectname`
which is specifically designed to access small files like Python packages.
I generally create a subfolder and reference it with an environment variable:

     export PREFIX=/global/common/software/projectname/zonca/python_prefix

Then I create a `env.sh` script in the source folder of the package (in Global Home) that loads
the environment:

    module load python/3.6-anaconda-4.4
    export PREFIX=/global/common/software/projectname/zonca/python_prefix
    export PATH=$PREFIX/bin:$PATH
    export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=$PREFIX/lib/python3.6/site-packages:$PYTHONPATH

This environment is automatically propagated to the computing nodes when I submit a SLURM script,
therefore I do not add any of these environment details to my SLURM scripts.

Then I can install a package there with:

    python setup.py install --prefix=$PREFIX

or from pip:

    pip install apackage --prefix=$PREFIX

It is also common to install a newer version of a package which is already provided by
the base environment:

    pip install apackage --ignore-installed --upgrade --no-deps --prefix=$PREFIX

## Simulations SLURM scripts and configuration files

I first create a repository on Github for my simulations and clone it to my home folder at NERSC.
I generally create a repository for each experiment, then I create a subfolder for each
type of simulation I am working on.

Inside a folder I create parameters files to configure my run and slurm scripts to launch the
simulations and put everything under version control immediately, I often create a Pull Request
on Github and ask my collaborators to cross-check the configuration before a submit a run.

Smaller input data files, even binaries, can be added for convenience to the Github repository.

Once a run has been validated, inside the simulation type folder I createa a subfolder `runs/201806_details_about_run` and
add a `README.md`, this will include all the details about the simulation.
I also tag both the core library I depend on and the simulation repository with the same name e.g.:

    git tag -a 201806_details_about_run -m "software version used for 201806_details_about_run"

I'll also add the path at NERSC of the input data and output results.

Then for future simulations I'll keep modifying the SLURM scripts and parameter files but always have
a reference to each previous version.

## Larger input data and output data

Larger input data and outputs are not suitable for version control and should live in a SCRATCH filesystem.
I always use the Global Scratch `$CSCRATCH` which is available both on Edison on Cori and also
from the Jupyter Notebook environment at: <https://jupyter.nersc.gov>.

I create a root folder for the project at:

    $CSCRATCH/projectname

Then a subfolder for each simulation type:

    $CSCRATCH/projectname/simulation_type_1
    $CSCRATCH/projectname/simulation_type_2

Then I symlink those inside the simulation repository as the folder `out/`:

    cd $HOME/projectname/simulation_type_1
    ln -s $CSCRATCH/projectname/simulation_type_1 out

Therefore I can setup my simulation software to save all results inside `out/201806_details_about_run`
and this is going to be written to `CSCRATCH`.

This setup makes it very convenient to regularly backup everything to tape using `cput` which just backs up
files that are not already on tape, e.g.:

    cd $CSCRATCH
    hsi
    cput -R projectname

This is going to synchronize the backup on tape with the latest results on `CSCRATCH`.

I do the same for input files:

    mkdir $CSCRATCH/projectname/input_simulation_type_1
    cd $HOME/projectname/simulation_type_1
    ln -s $CSCRATCH/projectname/input_simulation_type_1 input
