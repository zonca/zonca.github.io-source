Title: Setup automated testing on Github repository with Travis-ci
Date: 2017-09-06 18:00
Author: Andrea Zonca
Tags: github, travis, git
Slug: automated-testing-travis-ci-github

## Introduction

It is good practice in software development to implement extensive testing of the codebase in order to catch quickly any bug introduced into the code when implementing new features.

The suite of tests should be easy to execute (possibly one single command, for example with the `py.test` runner) and quick to run (more than 1 minute would make it tedious to run).

The developers should run the unit test suite every time they implement a change to the codebase to make sure anything else has not been broken.

However, once a commit has been pushed to Github, it is also great to have automated testing executed automatically, at least for 2 reasons:

  * Run tests in all the environments that need to be supported by the software, for example run with different versions of Python or different versions of a key required external dependancy
  * Run tests in a clean environment that has less risks of being contaminated by some mis-configuration on one of the developers' environments

## Travis-CI

Travis is a free web based service that allows to register a trigger on Github so that every time a commit is pushed to Github or a Pull Request is opened, it launches an isolated Ubuntu (even if it also supports Mac OS) container for each of the configurations that we want to test, builds the software (if needed) and then runs the test.

The only requirement is that the Github project needs to be Public for the free service. Otherwise there are paid plans for private repositories.

## Setup on Travis-CI

* Go to <http://travis-ci.org> and login with a Github account
* In order to automatatically configure the hook on Github Travis requests writing privileges to your Github account, annoying but convenient
* Leave all default options, just make sure that Pull Requests are automatically tested
* If you have the repository both under an organization and a fork under your account, you can choose either to test both or just the organization repository, anyway your pull requests will be tested before merging.

## Configuration of the repository

* Create a new branch on your repository:

        git checkout -b test_travis

* Add a `.travis.yml` (mind that it starts with a dot) configuration file
* Inside this file you can configure how your project is built and tested, for the simple case of `bash` or `perl` scripts you can just write:

        dist: trusty
		language: bash

		script:
			- cd $TRAVIS_BUILD_DIR/tests; bash run_test.sh

* Check the Travis-CI documentation for advanced configuration options
* Now push these changes to your fork of the main repository  and then create a Pull Request to the main repository
* Go to <https://travis-ci.org/YOUR_ORGANIZATION/YOUR_REPO> to check the build status and the log

## Python example

In the following example, Travis-CI will create 8 builds, each of the 4 versions of Python will be tested with the 2 versions of `numpy`:

	language: python
	python:
	  - "2.7"
	  - "3.4"
	  - "3.5"
	  - "3.6"
	env:
	  - NUMPY_VERSION=1.12.1
	  - NUMPY_VERSION=1.13.1
	# command to install dependencies, requirements.txt should NOT include numpy
	install:
	  - pip install -r requirements.txt numpy==$NUMPY_VERSION
	# command to run tests
	script:
	  - pytest # or py.test for Python versions 3.5 and below

## Badge in README

Aestetic touch, left click on the "Build Passing" image on the Travis-CI page for your repository, choose "Markdown" and paste the code to the `README.md` of your repository on Github. This will show in real time if the last version of the code is passing the tests or not.
