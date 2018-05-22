#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
IMAGE_NAME="condaforge/linux-anvil"
ARTIFACTS="$REPO_ROOT/build_artifacts"

docker info

# In order for the conda-build process in the container to write to the mounted
# volumes, we need to run with the same id as the host machine, which is
# normally the owner of the mounted volumes, or at least has write permission
HOST_USER_ID=$(id -u)
# Check if docker-machine is being used (normally on OSX) and get the uid from
# the VM
if hash docker-machine 2> /dev/null && docker-machine active > /dev/null; then
    HOST_USER_ID=$(docker-machine ssh $(docker-machine active) id -u)
fi

test -d "$ARTIFACTS" || mkdir "$ARTIFACTS"
DONE_CANARY="$ARTIFACTS/conda-forge-build-done"
rm -f "$DONE_CANARY"

docker run -it \
           -v ${REPO_ROOT}:/home/conda/staged-recipes \
           -e HOST_USER_ID=${HOST_USER_ID} \
           $IMAGE_NAME \
           bash \
           /home/conda/staged-recipes/.circleci/build_steps.sh

# verify that the end of the script was reached
test -f "$DONE_CANARY"
