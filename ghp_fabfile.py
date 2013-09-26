from fabric.api import *
from fabfile import DEPLOY_PATH


REMOTE_BRANCH = "master"
REMOTE_URL = "https:// @github.com:zonca/zonca.github.io.git"
COMMIT_MESSAGE = "deploy"

def init():
    local('rm -r {0}'.format(DEPLOY_PATH))
    local('mkdir {0}'.format(DEPLOY_PATH))
    with lcd(DEPLOY_PATH):
        local('git clone --quiet -b {remote_branch} {remote} .'.format(remote_branch=REMOTE_BRANCH, remote=REMOTE_URL))

def deploy():
    with lcd('output'):
        local('git add -A')
        local('git commit -m "{commit_message}"'.format(commit_message=COMMIT_MESSAGE))
        local('git push {remote} {remote_branch}'.format(remote_branch=REMOTE_BRANCH, remote="origin"))
