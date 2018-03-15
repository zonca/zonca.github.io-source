Start from Jupyterhub on Jetstream with Kubernetes at <https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html>

## Install Dask

install jupyterhub on namespace `pangeo` with name `jupyter`


sudo helm repo add dask https://dask.github.io/helm-chart/
sudo helm repo update
sudo helm install dask/dask --name=dask --namespace=pangeo

Then check that the `dask` instances are running:

```
$ sudo kubectl get pods --namespace pangeo
NAME                              READY     STATUS    RESTARTS   AGE
dask-jupyter-647bdc8c6d-mqhr4     1/1       Running   0          22m
dask-scheduler-5d98cbf54c-4rtdr   1/1       Running   0          22m
dask-worker-6457975f74-dqhsh      1/1       Running   0          22m
dask-worker-6457975f74-lpvk4      1/1       Running   0          22m
dask-worker-6457975f74-xzcmc      1/1       Running   0          22m                                          hub-7f75b59fc5-8c2pg              1/1       Running   0          6d
jupyter-zonca                     1/1       Running   0          10m
proxy-6bbf67f6bd-swt7f            2/2       Running   0          6d
```

### Access the scheduler and launch a distributed job

kubectl get service --namespace pangeo dask-scheduler

This gets the internal IP of the dask scheduler

We need to switch the single user image to pangeo, see `f3b05f08d300c60a8edbcfa934b75fc9c0ca54f3`

We can then login to JupyterHub and connect to the scheduler using the IP above:
actually `kube-dns` give a name to each service, so we can connect by name
```
from dask.distributed import Client
client = Client("dask-scheduler:8786")
client
```

Now we can access the 3 workers that we launched before:

```
Client
Scheduler: tcp://dask-scheduler:8786
Dashboard: http://dask-scheduler:8787/status

Cluster
Workers: 3
Cores: 10
Memory: 25.11 GB
```

We can run an example computation with dask array:

```
import dask.array as da
x = da.random.random((20000, 20000), chunks=(2000, 2000)).persist()
x.sum().compute()
```

### Access the Dask dashboard for monitoring job execution

need to setup ingress so that a path points to the Dask dashboard instead of Jupyterhub,

`sudo kubectl edit ingress jupyterhub -n pangeo`

```
spec:
  rules:
  - host: js-xxx-xx.jetstream-cloud.org
	http:
      paths:
      - backend:
          serviceName: dask-scheduler
          servicePort: 8787
        path: /dask-dashboard/
      - backend:
          serviceName: proxy-public
          servicePort: 80
        path: /
```

However I get 404 on <https://js-xxx-xxx.jetstream-cloud.org/dask-dashboard/>

FIXME will test later

## Allow users to launch Dask workers

We want users to be able to launch their own set of Kubernetes inside our cluster.

## Distributed data storage

    sudo kubectl create -f rook-object.yaml

now wait a couple of minutes and check that the pod is running:

```
kubectl -n rook get pod -l app=rook-ceph-rgw
                               NAME                                        READY     STATUS    RESTARTS   AGE
rook-
ceph-rgw-pangeostore-b75f9fcc9-r9vlb   1/1       Running   0          2m
```

    sudo kubectl create -f rook-tools.yaml

```
k get pod -n rook
NAME                                        READY     STATUS    RESTARTS   AGE
rook-api-d8dcbddd-mpp5n                     1/1       Running   0          13d                                rook-ceph-mgr0-5fbf8b8585-glg5v             1/1       Running   0          13d
rook-ceph-mgr1-75c47ffcc7-fpbpd             1/1       Running   0          13d
rook-ceph-mon1-4rbfm                        1/1       Running   0          14d
rook-ceph-mon4-jhpsj                        1/1       Running   0          10d
rook-ceph-mon5-bpqr9                        1/1       Running   0          2d
rook-ceph-osd-6krgs                         1/1       Running   1          13d
rook-ceph-osd-gt8jr                         1/1       Running   1          13d
rook-ceph-rgw-pangeostore-b75f9fcc9-r9vlb   1/1       Running   0          1h
rook-tools                                  1/1       Running   0          53m
```


Then access the `rook-tools` pod:

    kubectl -n rook exec -it rook-tools bash

Now from the root terminal `root@rook-tools` you can monitor and administer rook:

    rookctl status


```
ceph df
GLOBAL:
    SIZE       AVAIL      RAW USED     %RAW USED 
    73404M     69141M        4262M          5.81 
POOLS:
    NAME                              ID     USED       %USED     MAX AVAIL     OBJECTS                           replicapool                       1      76332k      0.08        21018M          51 
    pangeostore.rgw.control           2           0         0        21018M           8 
    pangeostore.rgw.meta              3           0         0        21018M           0 
    pangeostore.rgw.log               4          50         0        21018M         177 
    pangeostore.rgw.buckets.index     5           0         0        21018M           0 
    .rgw.root                         6        3746         0        21018M          16 
    pangeostore.rgw.buckets.data      7           0         0        42036M           0 

```


    rookctl object user create pangeostore s3user "somepassword"

You can get the configuration to access the object store which is compatible with S3

```
rookctl object connection pangeostore s3user --format env-var
export AWS_HOST=rook-ceph-rgw-pangeostore
export AWS_ENDPOINT=10.106.95.65:80
export AWS_ACCESS_KEY_ID=6RAF35IO4A3VTIAP15V0W
export AWS_SECRET_ACCESS_KEY=2mQRj7KNNfpklayduiHn8Vsds3B0sdfEZ3v5Q9uUKk3CvM
```



```
eval $(rookctl object connection pangeostore s3user --format env-var)
s3cmd mb --no-ssl --host=${AWS_HOST} --host-bucket=  s3://rookbucket
rookctl object bucket list pangeostore
```

Follow the steps to verify that object store is working, make sure you
are using the same version you installed with helm, crosscheck with `helm ls`:

https://github.com/rook/rook.github.io/blob/master/docs/rook/v0.6/client.md

This **DOES NOT WORK** upload seems to be completed but hangs there.
Also, Rook is in WARNING status. Should reduce the Placement Groups, but
not sure which pool I should modify.

## Use OpenStack swift for object storage

Natively provided by Jetstream, still alpha, but hey.

Need openstack RC file version 3 from: <https://iu.jetstream-cloud.org/project/api_access/>

    pip install python-openstackclient

source the openstackRC file, put the password, this is the TACC password, NOT the XSEDE Password. I know.

now create ec2 credentials with:

	openstack ec2 credentials create -f json > ec2.json

test if we can access this.

I installed this on `js-169-169`

actually we can skip ec2 credentials and just use openstack:

    openstack object list zarr_pangeo


```
[default]
region=RegionOne
aws_access_key_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
aws_secret_access_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

```
import s3fs
fs = s3fs.S3FileSystem(client_kwargs=dict(endpoint_url="https://iu.jetstream-cloud.org:8080"))
fs.ls("zarr_pangeo")
```

Zarr with dask on 1 node works fine

https://gist.github.com/zonca/071bbd8cbb9d15b1789865acb9e66de8

Need to test:
* access from multiple nodes with distributed
* test read-only access without authentication
