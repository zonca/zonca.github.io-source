Title: Jiffylab multiuser IPython notebooks
Date: 2013-10-14 10:30
Author: Andrea Zonca
Tags: python, ipython-notebook
slug: jiffylab-multiuser-ipython-notebooks

[jiffylab](https://github.com/ptone/jiffylab) is a very interesting project by [Preston Holmes](https://twitter.com/ptone) to provide sandboxed IPython notebooks instances on a server using [docker](http://www.docker.io/).
There are several user cases, for example:

* In a tutorial about `python`, give users instant access to a working IPython notebook
* In a tutorial about some specific `python` package, give users instant access to a python environment with that package already installed
* Give students in a research group access to `python` on a server with preinstalled several packages maintained and updated by an expert user.

## How to install [jiffylab](https://github.com/ptone/jiffylab) on Ubuntu 12.04

* [Install `docker` on Ubuntu Precise](http://docs.docker.io/en/latest/installation/ubuntulinux/#ubuntu-precise)
* Copy-paste each line of `linux-setup.sh` to a terminal, to check what is going on step by step
* To start the application, change user to `jiffylabweb`:
```bash
sudo su jiffylabweb
cd /usr/local/etc/jiffylab/webapp/
python app.py #run in debug mode
```
* Point your browser to the server to check debugging messages, if any.
* Finally start the application in production mode:

```bash
python server.py #run in production mode
```

## How `jiffylab` works

Each users gets a sandboxed IPython notebook instance, the user can save the notebooks and reconnect to the same session later. Main things missing:

* No real authentication system / no HTTPS connection, easy workaround would be to allow access only from local network/VPN/SSH tunnel
* No scientific packages preinstalled, need to customize the docker image to have `numpy`, `matplotlib`, `pandas`...
* No access to common filesystem, read-only, this I think is the most pressing feature missing, [issue already on Github](https://github.com/ptone/jiffylab/issues/12)

I think that just adding the common filesystem would be enough to make the project already usable to provide students a way to easily get started with python.

## Few screenshots

### Login page

<img src="/images/jiffylab_intro.png" alt="Jiffylab Login page" style="width: 730px;"/>


### IPython notebook dashboard

<img src="/images/jiffylab_dashboard.png" alt="Jiffylab IPython notebook dashboard" style="width: 730px;"/>

### IPython notebook

<img src="/images/jiffylab_notebook.png" alt="Jiffylab IPython notebook" style="width: 730px;"/>
