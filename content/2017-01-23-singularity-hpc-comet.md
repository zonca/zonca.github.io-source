Title: Run Ubuntu in HPC with Singularity
Date: 2017-01-13 12:00
Author: Andrea Zonca
Tags: singularity, comet
Slug: singularity-hpc-comet

* Ever wanted to `sudo apt install` packages on a Supercomputer?
* Ever wanted to freeze your software environment and reproduce a calculation after some time?
* Ever wanted to dump your software environment to a file and move it to another Supercomputer? or wanted the same software on your laptop and on a computing node?

If your answer to any of those question is yes, read on! Otherwise, well, still read on, it's awesome!

## Singularity

[Singularity](http://singularity.lbl.gov) is a software project by Lawrence Berkeley Labs to provide a safe container technology for High Performance Computing,
and it has been available for some time on my favorite Supercomputer, i.e. Comet at the San Diego Supercomputer Center.

You can read more details on their website, in summary you choose your own Operative System (any GNU/Linux distribution), describe its configuration in a standard format or even
import an existing `Dockerfile` (from the popular Docker container technology) and Singularity is able to build an image contained in a single file.
This file can then be executed on any Linux machine with Singularity installed (even on a Comet computing node), so you can run Ubuntu 16.10 or Red Hat 5 or any other flavor, your choice!
It doesn't need any deamon running like Docker, you can just execute a command inside the container by running:

    singularity exec /path/to/your/image.img your_executable

And your executable is run within the OS of the container.

The container technology is just sandboxing the environment, not executing a complete OS inside the host OS, so the loss of performance is minimal.

In summary, referring to the questions above:

* This allows you to `sudo apt install` any package inside this environment when it is on your laptop, and then copy it to any Supercomputer and run your software inside that OS.
* You can store this image to help reproduce your scientific results anytime in the future
* You can develop your software inside a Singularity container and never have to worry about environment issues when you are ready for production runs on HPC or moving across different Supercomputers

## Build a Singularity image for SDSC Comet with MPI support

One of the trickiest things for such technology in HPC is support for MPI, the key stack for high speed network communication. I have prepared a tutorial on Github on how to build either a CentOS 7 or a Ubuntu 16.04 Singularity container for Comet that allows to use the `mpirun` command provided by the host OS on Comet but execute a code that supports MPI within the container.

* <https://github.com/zonca/singularity-comet>

## More complicated setup for Julia with MPI support

For a project that needed a setup with Julia with MPI support I built a more complicated container, see:

* <https://github.com/zonca/singularity-comet/tree/master/debian_julia>

## Prebuilt containers

I made also available my containers on Comet, they are located in my scratch space:

`/oasis/scratch/comet/zonca/temp_project`

and are named `Centos7.img`, `Ubuntu.img` and `julia.img`.

You can also copy those images to your local machine and customize them more.

## Trial accounts on Comet

If you don't have an account on Comet yet, you can request a trial allocation:

<https://www.xsede.org/web/xup/allocations-overview#types-trial>

Enjoy!
