Title: Execute Jupyter Notebooks not interactively
Date: 2019-09-23 12:00
Author: Andrea Zonca
Tags: jupyter, notebook, condor
Slug: batch-notebook-execution

Over the years, I have explored how to scale up easily computation through
Jupyter Notebooks by executing them not-interactively, possibily parametrized
and remotely. This is mostly for reference.

* [`nbsubmit`](https://github.com/zonca/nbsubmit) is a Python package which has Python API to send a local notebook for execution on a remote SLURM cluster, for example Comet, see [an example](https://github.com/zonca/nbsubmit/blob/master/example/multiple_jobs/submit_multiple_jobs.ipynb). This project is not maintained right now.
* Back in 2017 I tested submitting notebooks to Open Science Grid, see [the `batch-notebooks-condor` repository](https://github.com/zonca/batch-notebooks-condor)
