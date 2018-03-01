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


