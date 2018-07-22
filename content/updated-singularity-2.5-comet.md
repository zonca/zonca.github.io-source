Title: Updated Singularity images for Comet
Date: 2018-07-22 12:00
Author: Andrea Zonca
Tags: singularity, comet
Slug: singularity-2.5-comet

Back in January 2017 I wrote a [blog post about running Singularity on Comet](https://zonca.github.io/2017/01/singularity-hpc-comet.html).

I recently needed to update all my container images to the latest scientific python packages,
so I also took the opportunity to create both a Docker auto-build repository on DockerHub
and a SingularityHub image.

Those images have a working MPI installation which has the same MPI version of Comet so
they can be used as a base for MPI programs.

The Docker image is based on the Jupyter Datascience notebook, therefore has Python, R and Julia.
the Singularity image on SingularityHub has instead only Python.
Anyway `singularity pull` also works with Docker containers, so also the Docker container can easily
be turned into a singularity container.

See <https://github.com/zonca/singularity-comet>
