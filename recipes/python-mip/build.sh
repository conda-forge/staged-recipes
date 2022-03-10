#!/bin/sh

set -ex

# take care of activation scripts;
# from https://conda-forge.org/docs/maintainer/adding_pkgs.html#activate-scripts

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# nuke vendored libraries
rm -rf mip/libraries/

export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"
export PMIP_CBC_LIBRARY=$PREFIX/lib/libCbc${SHLIB_EXT}

python -m pip install . -vv --prefix=$PREFIX
