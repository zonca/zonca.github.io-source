Title: Career as a computational scientist
Date: 2014-06-05 14:00
Author: Andrea Zonca
Tags: career, hpc
Status: draft
Slug: career-as-a-computational-scientist

Recently I've been asked what are the prospects of a wannabe computational scientist, 
both in terms of training and in terms of job opportunities.

So I am writing this blog post about my personal experience.

## What is a computational scientist

In my understanding, a computational scientist is a scientist with strong skills in scientific computing who
most of the day is building software.

Usually there are 2 main areas, in any field of science:

1. *Data analysis*: historically only few fields of science had to deal with large amount
    of experimental data, for example Astrophysics, nowadays instead every field has access
    to extremely large amount of data thanks to automatic collection of usage data/logs/clicks/images/videos
    at high sampling rate.
    Task of the computational scientist is generally to analyze the data, i.e. cleanup, check systematic effects,
    calibrate, understand and reduce to a form to be used for scientific exploitation.
1. *Simulations*: production of artificial data used for their own good in the understanding of scientific models or
    by trying to reproduce experimental data in order to characterize the response of a scientific instrument. 

## My experience

I trained as Aerospace Engineer for my Master degree, and then moved to a PhD in Astrophysics, in Milano,
where I worked in the Planck collaboration and took care of simulating the inband response of the Low Frequency Instrument
detectors.
During my PhD I developed a good proficiency with Python, mainly using it for task automation and plotting. 
My previous programming experience was very low, only some Matlab during last year of my Master degree, but I found Python really easy to use,
and learned it myself with books and online tutorials.
With no formal education in Computer Science, the most complicated concept to grasp is Object Oriented programming; at the time
I was moonlighting as a web developer and I familiarized with OO using Django models.
After my PhD I got a PostDoc position at the University of California, Santa Barbara, there I had for the first time
access to supercomputers and my job involved analyzing large amount of data.
During 4 years at UCSB I had the great opportunity of choosing my own tools, implementing my own software for data processing,
so I immediately saw the value of improving my understanding of software development best practices.

Unfortunately in science there is usually a push toward hacking around a quick and dirty solution to get out results and go forward,
I instead focused on learning how to build easily-maintenable libraries that I could re-use in the future. This
involved learning more advanced Python, version control, unit testing and so on.
It also helped that I became one of the core developers of `healpy`, a Python package for pixelized sky maps processing.

In 2013, at the 4th year of my PostDoc and with the Planck mission near to the end in 2015, I was looking for a position
as a computational scientist, mainly as a research scientist (i.e. doing research/data analysis full time, with a long term contract) 
at research labs like Berkeley Lab or Jet Propulsion Laboratory, or in a research group in Cosmology/Astrophysics or in
High Performance Computing.

I got hired at the San Diego Supercomputer Center in December 2013 as a permanent staff, here I collaborate with research groups in
any field of Science and help them deploy and optimize their software on supercomputers here at SDSC or in other XSEDE centers.

## Thoughts about a career as a computational scientist

Starting out as a computational scientist nowadays is quite easy, with a background in any field of science, it is possible to improve computational skills thanks to several learning resources, for example:

* Free online video classes on [Coursera](https://www.coursera.org/courses?search=python), [Udacity](https://www.udacity.com/courses#!/data-science) and others
* [Software Carpentry](http://software-carpentry.org) runs bootcamps for scientists to improve their computational skills
* Online tutorials on [Python for scientific computing](http://scipy-lectures.github.io/)
* Books, e.g. [Python for Data Analysis](http://shop.oreilly.com/product/0636920023784.do)

After a PhD program, a computational scientist with experience either in data analsys or simulation, especially if has experience in parallel programming, should quite easily find a position as a PostDoc, lots of research groups have huge amount of data and need software development skilled labor.

I believe what is complicated is the next step, faculty jobs favour scientists with the best scientific publications, and software development generally is not recognized as a first class scientific product.
Very interesting opportunities in Academia are "Research Scientist" positions either at research facilities, for example Lawrence Berkeley Labs and NASA Jet Propulsion Laboratory, or supercomputer centers. These jobs are often permament positions, unless the institution runs out of funding, and allow to work 100% on research.
Another opportunity is to work as "Research Scientist" in a specific research group in a University, this is less common, and depends on their availability of long-term funding.

Still, the total number of available positions in Academia is not very high, therefore it is very important to also keep open the opportunityof a job in Industry. Fortunately nowadays most  skills of a computational scientist are very well recognized in Industry, so I recommend to choose, whenever possible, to learn and use tools that are widely used also outside of Academia, for example Python, version control with Git, shell scripting, unit testing, databases, multi-core programming, parallel programming, GPU programming and so on.
