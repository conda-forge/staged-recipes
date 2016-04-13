#!/usr/bin/env bash

# NOTE: This script has been adapted from content generated by github.com/conda-forge/conda-smithy

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
IMAGE_NAME="pelson/obvious-ci:latest_x64"

config=$(cat <<CONDARC

channels:
 - conda-forge
 - defaults

show_channel_urls: True

CONDARC
)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}/recipes:/conda-recipes \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

if [ "${BINSTAR_TOKEN}" ];then
    export BINSTAR_TOKEN=${BINSTAR_TOKEN}
fi

# Unused, but needed by conda-build currently... :(
export CONDA_NPY='19'

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda update --yes conda conda-build
conda install --yes anaconda-client obvious-ci
conda install --yes conda-build-all

conda info

### Make sure we are using UTF-8 encoding.
# This has generally been found to be a good move especially when handling Python code or text
# that ends up having UTF-8 characters. We should improve on this by configuring `locales`.
export LANG=en_US.UTF-8

# These are some standard tools. But they aren't available to a recipe at this point (we need to figure out how a recipe should define OS level deps)
#yum install -y expat-devel git autoconf libtool texinfo check-devel

# These were specific to installing matplotlib. I really want to avoid doing this if possible, but in some cases it
# is inevitable (without re-implementing a full OS), so I also really want to ensure we can annotate our recipes to
# state the build dependencies at OS level, too.
yum install -y libXext libXrender libSM tk libX11-devel mesa-libGL-devel

# We don't need to build the example recipe.
rm -rf /conda-recipes/example

# A better way to handle yum requirements.
find conda-recipes -mindepth 2 -maxdepth 2 -type f -name "yum_requirements.txt" | xargs -n1 cat | xargs -r yum install -y

conda-build-all /conda-recipes --matrix-conditions "numpy >=1.9" "python >=2.7,<3|>=3.4"

EOF
