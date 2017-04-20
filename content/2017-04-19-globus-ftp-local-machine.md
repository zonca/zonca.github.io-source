Title: Configure Globus on your local machine for GridFTP with XSEDE authentication
Date: 2017-04-19 12:00
Author: Andrea Zonca
Tags: ipython, jupyterhub
Slug: globus-gridftp-local

All the commands are executed on your local machine, the purpose of this tutorial is to be able to use `globus-url-copy` to copy efficiently data back and forth between your local machine and a XSEDE Supercomputer on the command line.

For a simpler point and click web interface, install Globus Conect Personal instead: <https://www.globus.org/globus-connect-personal>

## Install Globus toolkit

See http://toolkit.globus.org/toolkit/docs/latest-stable/admin/install/#install-toolkit

On Ubuntu, download the deb of the Globus repo from:

    wget http://www.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
    sudo dpkg -i globus-toolkit-repo_latest_all.deb
    sudo apt-get install globus-data-management-client

## Install XSEDE certificates on your machine

    wget https://software.xsede.org/security/xsede-certs.tar.gz
    tar xvf xsede-certs.tar.gz
    sudo mv certificates /etc/grid-security

Full instructions here:

<https://software.xsede.org/production/CA/CA-install.html>

## Authenticate with the myproxy provided by XSEDE

Authenticate with your XSEDE user and password:

    myproxy-logon -s myproxy.xsede.org -l $USER -t 36
    
You can specify the lifetime of the certificate in hours with `-t`.
    
you should get a certificate:

    A credential has been received for user zonca in /tmp/x509up_u1000.
    
You can check how much time is left on a certificate by running `grid-proxy-info`.
    
## Run globus-url-copy

For example copy to my home on Comet:

    globus-url-copy -vb -p 4 local_file.tar.gz gsiftp://oasis-dm.sdsc.edu///home/zonca/

See the quickstart guide on the most used `globus-url-copy` options:

<http://toolkit.globus.org/toolkit/docs/latest-stable/gridftp/user/#gridftp-user-basic>
    
## Synchronize 2 folders

Only copy new files using the `-sync` and `-sync-level` options:

```
-sync
  Only transfer files where the destination does not exist or differs from the source. -sync-level controls how to determine if files differ.
-sync-level number
  Criteria for determining if files differ when performing a sync transfer. The default sync level is 2.\
```

The available levels are:
  
* Level 0 will only transfer if the destination does not exist.
* Level 1 will transfer if the size of the destination does not match the size of the source.
* Level 2 will transfer if the time stamp of the destination is older than the time stamp of the source.
* Level 3 will perform a checksum of the source and destination and transfer if the checksums do not match.
