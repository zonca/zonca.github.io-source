Title: How to automatically build your Pelican blog and publish it to Github Pages
Date: 2013-09-26 13:45
Author: Andrea Zonca
Tags: python, travis-ci, github
slug: automatically-build-pelican-and-publish-to-github-pages

Something I like a lot about Jekyll, the Github static blog generator, is that you just push commits to your repository and Github takes care of re-building and publishing your website.
Thanks to this, it is possible to create a quick blog post from the Github web interface, without the need to use a machine with Python environment.

The Pelican developers have a [method for building and deploying Pelican on Heroku](http://blog.getpelican.com/using-pelican-with-heroku.html), which is really useful, but I would like instead to use Github Pages.

I realized that the best way to do this is to rely on [Travis-CI](https://travis-ci.org/), as the build/deploy workflow is pretty similar to install/unit-testing Travis is designed for.

## How to setup Pelican to build on Travis

I suggest to use 2 separate git repositories on Github for the source and the built website, let's first only create the repository for the source:

* create the `yourusername.github.io-source` repository for Pelican and add it as `origin` in your Pelican folder repository

add a `requirements.txt` file in your Pelican folder:

<script src="http://gist-it.appspot.com/github/zonca/zonca.github.io-source/blob/master/requirements.txt"></script>

add a `.travis.yml` file to your repository:

<script src="http://gist-it.appspot.com/github/zonca/zonca.github.io-source/blob/master/.travis.yml"></script>

In order to create the encrypted token under env, you can login to the Github web interface to get an [Authentication Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use), and then install the `travis` command line tool with:

    # on Ubuntu you need ruby dev
    sudo apt-get install ruby1.9.1-dev
    sudo gem install travis

and run from inside the repository:

    travis encrypt GH_TOKEN=LONGTOKENFROMGITHUB --add env.global

Then add also the `deploy.sh` script and update the global variable with yours:

    github:zonca/zonca.github.io-source/deploy.sh

Then we can create the repository that will host the actual blog:

* create the `yourusername.github.io` repository for the website (with initial readme, so you can clone it)

Finally we can connect to [Travis-CI](https://travis-ci.org/), connect our Github profile and activate Continous Integration on our `yourusername.github.io-source` repository.

Now, you can push a new commit to your source repository and check on Travis if the build and deploy is successful, hopefully it is (joking, no way it is going to work on the first try!).
