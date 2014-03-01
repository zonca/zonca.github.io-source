Title: Build Software Carpentry lessons with Pelican
Date: 2014-02-26 23:00
Author: Andrea Zonca
Tags: python, software-carpentry, pelican
Slug: build-software-carpentry-with-pelican

[Software Carpentry](http://www.software-carpentry.org) offers bootcamps for scientist to teach basic programming skills.
All the material, mainly about bash, git, Python and R is [available on Github](http://github.com/swcarpentry/bc) under Creative Commons.

The content is either in Markdown or in IPython notebook format, and is currently built using Jekyll, nbconvert and Pandoc.
Basicly the requirement is to make it easy for bootcamp instructors to setup their own website, modify the content, and have the website updated.

I created a fork of the Software Carpentry repository and configured Pelican for creating the website:

* [bootcamp-pelican repository](https://github.com/swcarpentry-pelican/bootcamp-pelican): contains Markdown lessons in `lessons` (version v5), `.ipynb` in `notebooks` and news items in `news`.
* [bootcamp-pelican Github pages](https://github.com/swcarpentry-pelican/swcarpentry-pelican.github.io): This repository contains the output HTML
* [bootcamp-pelican website](http://swcarpentry-pelican.github.io/): this is the URL where Github publishes automatically the content of the previous repository

Pelican handles fenced code blocks, see <http://swcarpentry-pelican.github.io/> and conversion of IPython notebooks, see <http://swcarpentry-pelican.github.io/lessons/numpy-notebook.html>

## How to setup the repositories for a new bootcamp

1. [create a new Organization on Github](https://github.com/organizations/new) and add all the other instructors, name it: `swcarpentry-YYYY-MM-DD-INST` where `INST` is the institution name, e.g. `NYU`
1. [Fork the `bootcamp-pelican` repository](https://github.com/swcarpentry-pelican/bootcamp-pelican/fork) under the organization account
1. Create a new repository in your organization named `swcarpentry-YYYY-MM-DD-INST.github.io` that will host the HTML of the website, also tick **initialize with README**, it will help later.

Now you can either prepare the build environment on your laptop or have the web service `travis-ci` automatically update the website whenever you update the repository (even from the Github web interface!).

## Build/Update the website from your laptop

1. Clone the `bootcamp-pelican` repository of your organization locally
1. Create a `Python` virtual environment and install requirements with:

        cd bootcamp-pelican
        virtualenv swcpy
        . swcpy/bin/activate
        pip install -r requirements.txt
        
1. Clone the `swcarpentry-YYYY-MM-DD-INST.github.io` in the output folder as:

        git clone git@github.com:swcarpentry-YYYY-MM-DD-INST.github.io.git output

1. Build or Update the website with Pelican running

        fab build
        
1. You can display the website in your browser locally with:

        fab serve

1. Finally you can publish it to Github with:

        cd output
        git add .
        git push origin master
        
## Configure Travis-ci to automatically build and publish the website

1. Go to <http://travis-ci.org> and login with Github credentials
1. Under <https://travis-ci.org/profile> click on the organization name on the left and activate the webhook setting `ON` on your `bootcamp-pelican` repository
1. Now it is necessary to setup the credentials for `travis-ci` to write to the repository
1. Go to https://github.com/settings/tokens/new, create a new token with default permissions
1. Install the `travis` tool (in debian/ubuntu `sudo gem install travis`) and run from any machine (not necessary to have a clone of the repository):

        travis encrypt -r swcarpentry-YYYY-MM-DD-INST/bootcamp-pelican GH_TOKEN=TOKENGOTATTHEPREVIOUSSTEP
   
otherwise I've setup a web application that does the encryption in your browser, see: <http://travis-encrypt.github.io>
1. Open `.travis.yml` on the website and replace the string under `env: global: secure:` with the string from `travis encrypt`
1. Push the modified `.travis.yml` to trigger the first build by Travis, and then check the log on <http://travis-ci.org>

Now any change on the source repository will be picked up automatically by Travis and used to update the website.
