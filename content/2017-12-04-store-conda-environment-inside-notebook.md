Title: Store a conda environment inside a Notebook
Date: 2017-12-04 18:00
Author: Andrea Zonca
Tags: jupyter-notebook
Slug: store-conda-environment-inside-notebook

Last August, during the Container Analysis Environments Workshop held at Urbana-Champaign,
we had discussion about reproducibility in the Jupyter Notebooks.
There came out the idea of storing all the details about the Python environment inside the Notebook,
in the metadata.

I released an experimental package on Github (and PyPI):

<https://github.com/zonca/nbenv>

For simplicity it only supports `conda` environment, but it also supports having `pip`-installed packages
inside those environments.

It automatically saves the `conda` environment as metadata inside the `.ipynb` document and then provides
a command line tool to inspect it and create a new `conda` environment based on it.

I am not sure this is the best design, please open Issues on Github to send me feedback!
