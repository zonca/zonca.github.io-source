#!/usr/bin/env bash
BRANCH=master
REPO=zonca/zonca.github.io.git
PELICAN_OUTPUT_FOLDER=output

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo -e "Starting to deploy to Github Pages\n"
    #go to home and setup git
    #cd $HOME
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis"
    #using token clone gh-pages branch
    git clone --quiet --branch=$BRANCH https://${GH_TOKEN}@github.com/$REPO built_website > /dev/null
    #go into diractory and copy data we're interested in to that directory
    cd build_website
    cp -Rf ../$PELICAN_OUTPUT_FOLDER/* .
    #add, commit and push files
    git add -f .
    git commit -m "Travis build $TRAVIS_BUILD_NUMBER pushed to Github Pages"
    git push -fq origin $BRANCH > /dev/null
    echo -e "Deploy completed\n"
fi
