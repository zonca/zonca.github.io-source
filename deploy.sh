#!/usr/bin/env bash
BRANCH=master
TARGET_REPO=zonca/zonca.github.io.git
PELICAN_OUTPUT_FOLDER=output

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo -e "Starting to deploy to Github Pages\n"
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis"
    #using token clone gh-pages branch
    #git clone --quiet --branch=$BRANCH https://${GH_TOKEN}@github.com/$TARGET_REPO built_website > /dev/null
    git clone --quiet --branch=$BRANCH https://c26f7c12d444e95f45f9bcf535d2e719743b6036@github.com/$TARGET_REPO built_website
    #go into directory and copy data we're interested in to that directory
    cd build_website
    cp -Rf ../$PELICAN_OUTPUT_FOLDER/* .
    #add, commit and push files
    git add -f .
    git commit -m "Travis build $TRAVIS_BUILD_NUMBER pushed to Github Pages"
    git push -fq origin $BRANCH > /dev/null
    echo -e "Deploy completed\n"
fi
