Title: Bring your computing to the San Diego Supercomputer Center
Date: 2018-10-24 18:00
Author: Andrea Zonca
Tags: comet, sdsc, xsede
Slug: compute-at-sdsc

I am often asked what computing resources are available at the San Diego Supercomputer Center for scientists and what is the best way to be granted access. I decided to write a blog post with an overview of all the options, consider that I'm writing this in October 2018, so please cross-check on the official websites.

## Comet

Our key resource is the Comet Supercomputer, a 2000 nodes traditional supercomputer with 72 GPU nodes, each with 4 GPUs.
Comet has powerful CPUs with 24 cores and lots of memory per node (128GB) and a very fast local flash drive on each node.
It is also suitable to run large amounts of single node jobs, so you can exploit it even if you don't have a multi-node parallel software.

Comet is a XSEDE resource, XSEDE is basically a consortium of many large US supercomputers dedicated to Science,  it reviews applications from US scientists and grants them supercomputing resources for free. It is funded by National Science Foundation.

### How to request resources on Comet

Ordered from the easiest / lower amount of resources to the largest allocations.

The amount of resources on Comet are billed in core hours (sometimes named SUs), if you request a Comet node for 1 hour you are charged 24 hours, comet GPUs are billed 14 core hours for each hour on each GPU. The newest Comet GPU nodes have P100 instead of K80, those are billed 1.5 times the older GPU nodes, i.e. 21 core hours per hour.
Comet also has a shared queue where you can request and be charged for a portion of a Comet node (you also get the proportional amount of memory), i.e. you can request 6 cores and pay only 6 core hours per hour and get access to 32GB of RAM.

#### Trial allocation

Anybody can request a trial allocation on Comet with a quick 1 page justification and be approved within a day for 1000 core hours to be used within 6 month. This is useful to try Comet out, run some test jobs. See the [trial allocation page on the XSEDE website](https://portal.xsede.org/allocations/startup#trial).

#### Campus champions

Most US universities have a reference person that facilitates access to XSEDE supercomputers, it is often somebody in the Information Technology office or in a Chancellor of Research or a professor. This person is given a large amount of supercomputing hours on all XSEDE resources and local professors, postdocs and graduate students can request to be added to this allocation and use many thousands of core hours, depending on availability.
Campus champions are currently available in 241 (!!) US institutions, [see the list on the XSEDE website](https://www.xsede.org/web/site/community-engagement/campus-champions/current).

#### HPC@UC

If you are at any of the University of California campuses, you have an expedited way of getting resources at SDSC.
You can submit a request for up to 1 million core hours (more often ~500K core hours) on Comet on the [HPC@UC page](http://www.sdsc.edu/collaborate/hpc_at_uc.html). It just requires a 3 page justification and is answered within 10 business days. You are not eligible if your research group has an active XSEDE allocation.

#### Startup allocation

Startup allocations are really quick to prepare, they just require a 1 page justification and CV of the Principal Investigator and grant up to 50K core hours on Comet, if your research is funded by NSF/NASA/NIH remember to specify that. See the [startup page on XSEDE for more details](https://portal.xsede.org/allocations/startup).

They are reviewed continously so you should be approved within a few days. Generally you are supposed to utilize the amount of hours within 1 year, but if your science project is funded for a longer period, you can request a multi-year allocation.

#### XRAC allocation

XRAC allocations are full fledged proposals, you can request up to a few million hours on Comet, here you must provide a detailed justification of the resources requested, demonstrate that your software is able to efficiently scale up in parallel, i.e. if in production you want to run on 100 nodes, you should run it on 5/10/50/100 nodes and check that performance does not degrade too much with increased parallelism.
You should have performed those tests in a startup allocation.
The XRAC requests are reviewed quarterly, see the [Research allocations page](https://portal.xsede.org/allocations/research), there is also a recorded webinar.

## Triton Shared Computing Cluster

On TSCC you pay for one or more nodes that is bought and added to the cluster for 3 years with full hardware warranty plus 1 extra year with no warranty, so if it breaks it needs to be removed.
You pay a fixed price to buy the node (~$6K) plus yearly operations (~$1.8K if not subsidized by your University, in UC campuses this is generally subsidized and is ~$.5K), see [the updated costs on the TSCC page](http://www.sdsc.edu/services/hpc/tscc-purchase.html), also get in touch with them directly for more details.  You can also buy a node with GPUs.

Then, instead of having direct access to that node, you are given an allocation as big as the computing hours that your node provides to the cluster. This is great because it allows you to not be penalized for incosistent usage patterns. You can pay for 1 node and then use tens of nodes together once in a while. If you have the yearly operations subsidized by campus, the cost per core hour is about $2c, which is quite competitive, and the cluster is in SDSC machine room and professionally managed, updated, backed up.

## Colocation

Larger collaborations might need dedicated resources, it is possible to buy your own nodes, in units of entire racks (48 Rack Units), which depending on the type of blades can be 12 or 24 nodes and colocate it in SDSC's machine room. See the detailed cost on the [colocation page](http://www.sdsc.edu/services/it/colocation.html), this is a custom solution and it is not easy to give a simple cost estimate, better write and ask for a quote.

## Cloud resources (Virtual Machines)

SDSC also manages a OpenStack deployment, which is especially suitable for running services, for example websites, databases, APIs but it is also suitable to run long-running single node jobs or interactive data analysis (think Jupyter Notebooks). And Kubernetes, of course! (see my [tutorial for Jetstream, which works also on SDSC Cloud](https://zonca.github.io/2018/09/kubernetes-jetstream-kubespray.html).
This is also equivalent to Amazon Elastic Cloud Compute (EC2), here you pay for what you use, within UC you provide an funding index and that is charged for each hour used, see the full pricing on the [SDSC cloud page](http://www.sdsc.edu/services/it/cloud.html), roughly you are charged $8c an hour for a Virtual Machine with 1 core and 4GB of RAM.

## Feedback

If you have questions please email me at zonca on the sdsc.edu domain or twit @andreazonca.
