#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
ARTIFACTS="$REPO_ROOT/build_artifacts"
THISDIR="$( cd "$( dirname "$0" )" >/dev/null && pwd )"
PROVIDER_DIR="$(basename "$THISDIR")"
AZURE="${AZURE:-False}"

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

if [ -z "${IMAGE_NAME}" ]; then
    SHYAML_INSTALLED="$(shyaml -h || echo NO)"
    if [ "${SHYAML_INSTALLED}" == "NO" ]; then
        echo "WARNING: DOCKER_IMAGE variable not set and shyaml not installed. Falling back to quay.io/condaforge/linux-anvil-comp7"
        IMAGE_NAME="quay.io/condaforge/linux-anvil-comp7"
    else
        IMAGE_NAME="$(cat "${REPO_ROOT}/.ci_support/${CONFIG}.yaml" | shyaml get-value docker_image.0 quay.io/condaforge/linux-anvil-comp7 )"
    fi
fi

mkdir -p "$ARTIFACTS"
DONE_CANARY="$ARTIFACTS/conda-forge-build-done"
rm -f "$DONE_CANARY"

DOCKER_RUN_ARGS="-it"

if [ "${AZURE}" == "True" ]; then
    DOCKER_RUN_ARGS=""
fi

docker run ${DOCKER_RUN_ARGS} \
           -v "${REPO_ROOT}:/home/conda/staged-recipes" \
           -e HOST_USER_ID=${HOST_USER_ID} \
           -e AZURE=${AZURE} \
           -e CONFIG \
           -e CI \
           -e CF_CUDA_VERSION \
           $IMAGE_NAME \
           bash \
           "/home/conda/staged-recipes/${PROVIDER_DIR}/build_steps.sh"

# verify that the end of the script was reached
test -f "$DONE_CANARY"
