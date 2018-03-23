Title: Use the distributed file format Zarr on Jetstream Swift object storage
Date: 2018-03-03 18:00
Author: Andrea Zonca
Tags: jupyter, jetstream, zarr
Slug: zarr-on-jetstream

## Zarr

Zarr is a pretty new file format designed for cloud computing, see [documentation](http://zarr.readthedocs.io) and [a webinar](https://www.youtube.com/watch?v=np_p4JBAIYI) for more details.

Zarr is also supported by [dask](http://dask.pydata.org), the parallel computing framework for Python,
and the Dask team implemented storage backends for [Google Cloud Storage](https://github.com/dask/gcsfs) and
[Amazon S3](https://github.com/dask/s3fs).

## Use OpenStack swift on Jetstream for object storage

Jetstream also offers (currently in beta) access to object storage via OpenStack Swift.
This is a separate service from the Jetstream Virtual Machines, so you do not need to spin
any Virtual Machine dedicated to storing the data but just use the object storage already
provided by Jetstream.

## Read Zarr files from object store

If somebody else has already made available some files on object store and set their visibility
to "public", anybody can read them.

See the [example Notebook to read Zarr files](https://gist.github.com/zonca/bda69ab917bde831845d530e52eae6e5).

OpenStack Swift already provides an endpoint which has an interface compatible with Amazon S3, therefore
we can directly use the `S3FileSystem` provided by `s3fs`.

Then we can build a `S3Map` object which `zarr` and `xarray` can access.
I removed the endpoint url from the Notebook to avoid test traffic. You can request it to
the XSEDE helpdesk.

In this example I am using the `distributed` scheduler on a single node, you can scale up your computation
having workers distributed on multiple nodes, just make sure that all the workers have access to the
`zarr`, `xarray`, `s3fs` packages.

## Write Zarr files or read private files

In this case we need authentication.

First you need to ask to the XSEDE helpdesk API access to Jetstream, this also gives access
to the Horizon interface, which has many advanced features that are not available in Atmosphere.

### Create a bucket

Object store systems are organized on buckets, which are like root folders of our filesystem.
From the Horizon interface, we can choose Object Store -> Containers (quite confusing way of referring to buckets in OpenStack).
Here we can check content of existing buckets or create a new one.

### Get credentials

From Horizon, choose the project you want to charge usage from the dropdown menu at the top.

Then download the openstack RC file version 3 from: <https://iu.jetstream-cloud.org/project/api_access/>

At this point we need to transform it into Amazon-style credentials, you can do this on
any host, not necessarily on Jetstream, install OpenStack client:

    pip install python-openstackclient

source the openstackRC file, put the password, this is the TACC password (the same used to access Horizon), NOT the XSEDE Password.

Now we can check the content of the bucket we created above:

    openstack object list my_bucket

Now create ec2 credentials with:

	openstack ec2 credentials create

This is going to display AWS access key and AWS secret, we can save credentials in `~/.aws/config`
in the machine we want then use to write to object store.
```
[default]
region=RegionOne
aws_access_key_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
aws_secret_access_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Test access

We can check if we can successfully login using `s3fs`, notice we **do not use** `anon=True` as
we did before:

```
import s3fs
fs = s3fs.S3FileSystem(client_kwargs=dict(endpoint_url="JETSTREAM_SWIFT_ENDPOINT"))
fs.ls("my_bucket")
```

### Read a file from local filesystem and write to Object store

See [this notebook as an example of writing to object store](https://gist.github.com/zonca/f7cb1c7845f6b821dc8d178f84253ba3),
first we make sure to have the necessary Python packages,
then we use `xarray` to read data from NetCDF and then write back to Zarr first locally and then
via `s3fs` to Openstack Swift.

See the Zarr documentation about how to tweak, compression, data transformations and chunking.
