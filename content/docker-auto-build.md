Title: Create DockerHub auto build
Date: 2018-07-19 18:00
Author: Andrea Zonca
Tags: docker, github
Slug: create-dockerhub-autobuild

It is very convenient to create Autobuild repositories on DockerHub linked to
a Github repository with a `Dockerfile`.
Then every time you commit to Github, Dockerhub is going to build the image on
their service and make it available on <https://hub.docker.com> and can quickly
be pulled to any other system that supports Docker or Singularity.

Unfortunately if you have many Github organizations and repositories, the process
to set a new repository up gets stuck.

Fortunately we can bypass the issue by directly accessing the right URL, as suggested
[on StackOverflow](https://stackoverflow.com/questions/42792240/dockerhub-create-automated-build-step-stuck-at-creating).

I created a simple page to make this quicker, add the right parameters and it automatically
builds the right URL, see:

<https://zonca.github.io/docker-auto-build>
