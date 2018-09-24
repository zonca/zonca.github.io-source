## Test persistent storage with cinder

kubectl get storageclass
NAME                 PROVISIONER            AGE
standard (default)   kubernetes.io/cinder   1h

    kubectl create -f alpine-pv.yaml


 kubectl label node/kubespray-k8s-node-nf-1 failure-domain.beta.kubernetes.io/zone=nova --overwrite

    kubectl exec -it alpine -- /bin/bash

look into `df -h`, check that there is a 5GB mounted filesystem which is persistent.

    openstack volume list


```
openstack volume list
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
| ID                                   | Name                                                        | Status | Size | Attached to                                      |
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
| 508f1ee7-9654-4c84-b1fc-76dd8751cd6e | kubernetes-dynamic-pvc-e83ec4d6-bb9f-11e8-8344-fa163eb22e63 | in-use |    5 | Attached to kubespray-k8s-node-nf-1 on /dev/sdb  |
+--------------------------------------+-------------------------------------------------------------+--------+------+--------------------------------------------------+
```

## Test ReplicaSets, Services and Ingress

From Kubernetes in Action:
<https://github.com/luksa/kubernetes-in-action/tree/master/Chapter02/kubia>

    cd kubia_test_ingress
    kubectl create -f kubia-manual.yaml
    kubectl get pods -o wide


On one of the nodes:

    $ curl $KUBIA_MANUAL_IP:8080
    You've hit kubia-manual

    kubectl delete -f kubia-manual.yaml

### Load balancing with ReplicaSets and Services

    kubectl create -f kubia-replicaset.yaml
    kubectl create -f kubia-service.yaml


```
$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   22h
kubia        ClusterIP   10.233.28.205   <none>        80/TCP    45m
```

    curl $KUBIA_SERVICE_IP

This is on port 80 so we don't need `:8080` in the URL.
Run many times and check different kubia services answer.

### Publish service externally with ingress

Try to open browser and access the hostname of your master node at:

    http://js-XXX-YYY.jetstream-cloud.org

Where XXX-YYY are the last 2 groups of digits of the floating IP of the master instance,
i.e. AAA.BBB.XXX.YYY, each of them could also be 1 or 2 digits instead of 3.

The connection should be refused or hang.

Now:

    kubectl create -f kubia-ingress.yaml
    kubectl get ingress

Try again in the browser.

## Install Jupyterhub

    bash configure_helm_jupyterhub.sh
    bash install_jhub.sh

Check some preliminary pods running with:

    kubectl get pods -n jhub

Once the `proxy` is running, even if `hub` is still in preparation, you can check
in browser, you should get "Service Unavailable" which is a good sign that
the proxy is working.
