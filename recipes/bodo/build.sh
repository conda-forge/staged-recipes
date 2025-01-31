set -exo pipefail

# Conda-Build deletes .git, so we need to determine the version beforehand
# and then pass it to setuptools_scm in the build script (setup.py).
# https://conda-forge.org/docs/maintainer/knowledge_base.html#using-setuptools-scm
export SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION"

export CONDA_PREFIX_OLD=$CONDA_PREFIX
export CONDA_PREFIX=$PREFIX
export CMAKE_GENERATOR='Ninja'

$PYTHON -m pip install \
    --no-deps --no-build-isolation -vv \
    --config-settings=build.verbose=true \
    --config-settings=logging.level="DEBUG" \
    --config-settings=cmake.args="-DCMAKE_C_COMPILER=$CC;-DCMAKE_CXX_COMPILER=$CXX;-DCMAKE_INSTALL_PREFIX=$PREFIX;-DCMAKE_INSTALL_LIBDIR=lib;-DCMAKE_FIND_ROOT_PATH='$PREFIX;$CONDA_PREFIX_OLD/x86_64-conda-linux-gnu/sysroot';-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" \
    .
