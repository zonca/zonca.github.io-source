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
