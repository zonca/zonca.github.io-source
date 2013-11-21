Title: Published paper on Destriping Cosmic Microwave Background Polarimeter data
Date: 2013-11-20 21:30
Author: Andrea Zonca
Tags: python, paper, destriping, openscience
slug: published-paper-destriping-CMB-polarimeter

TL;DR version:

* Preprint on arxiv: [Destriping Cosmic Microwave Background Polarimeter data](http://arxiv.org/abs/1309.5609)
* Destriping `python` code on github: [`dst`](https://github.com/zonca/dst)
* Output maps and sample input data on figshare: [BMachine 40GHz CMB Polarimeter sky maps](http://figshare.com/articles/BMachine_40GHz_CMB_Polarimeter_sky_maps/644507)
* (Paywalled published paper: [Destriping Cosmic Microwave Background Polarimeter data](http://dx.doi.org/10.1016/j.ascom.2013.10.002))

My last paper was published by [Astronomy and Computing](http://www.journals.elsevier.com/astronomy-and-computing/).

The paper is focused on Cosmic Microwave Background data destriping, a map-making tecnique which exploits the fast
scanning of instruments in order to efficiently remove correlated low frequency noise, generally caused by thermal
fluctuations and gain instability of the amplifiers.

The paper treats in particular the case of destriping data from a polarimeter, i.e. an instrument which directly measures
the polarized signal from the sky, which allows some simplification compared to the case of a simply polarization-sensitive
radiometer.

I implemented a fully parallel `python` implementation of the algorithm based on:

* [`PyTrilinos`](http://trilinos.sandia.gov/packages/pytrilinos/) for Distributed Linear Algebra via MPI
* `HDF5` for I/O
* `cython` for improving the performance of the inner loops

The code is available on Github under GPL.

The output maps for about 30 days of the UCSB B-Machine polarimeter at 37.5 GHz are available on FigShare.

The experience of publishing with ASCOM was really positive, I received 2 very helpful reviews that drove me to
work on several improvements on the paper.
