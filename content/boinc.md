create new instance 16.04 with Docker
create volume and attach to instance

we want the volume to be used for all docker storage,
so.

    sudo systemctl stop docker

    sudo mv /var/lib/docker/* /vol_b/

    sudo umount /vol_b


Replace `/vol_b` with `/var/lib/docker`

```
zonca@js-xxx-xxx:~$ cat /etc/fstab
LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
/dev/sdb /var/lib/docker ext4 defaults,nofail 0 2
```

    sudo mount /var/lib/docker


update docker to a more recent version, see script
https://gist.github.com/zonca/f5faba190f5285c68dad48e897622e90

taken from kubeadm-bootstrap


sudo apt remove docker-compose docker

https://docs.docker.com/compose/install/#install-compose

    sudo adduser $USER docker

logout and back in
Check permissions are fine to run docker commands without sudo

    docker ps


follow instructions here:
https://github.com/marius311/boinc-server-docker

    URL_BASE=http://$(hostname) docker-compose up -d
