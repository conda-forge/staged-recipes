#!/bin/env bash

# Abort script upon untested failure
set -e

make Configure name=linux

make CC=${CC}

# Run a small sample of the test suite
make Samples

# Deploy to icon and bin directories at PREFIX
mkdir -p ${PREFIX}/bin
DEPLOY=${PREFIX}/icon
mkdir -p ${DEPLOY}

# remove compilation intermediates
make Clean || echo Clean exit code is $?

# Install by copy to give users full access to source, e.g., so that they can
#   use it for reference when building loadable C functions.
cp -R ${SRC_DIR}/* ${DEPLOY}
# Clean out extra files if necessary
pushd ${DEPLOY}
if [ -f build_env_setup.sh ]; then
  rm build_env_setup.sh
fi
if [ -f conda_build.sh ]; then
  rm conda_build.sh
fi
if [ -f metadata_conda_debug.yaml ]; then
  rm metadata_conda_debug.yaml
fi
popd

# Put executables onto the path
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)

# Create or append activation script to set IPL envar and give tips
mkdir -p ${PREFIX}/etc/conda/activate.d
echo '#!/bin/sh
if [ -d ${CONDA_PREFIX}/icon/ipl ]; then
  export IPL_OLD=${IPL}
  export IPL=${CONDA_PREFIX}/icon/ipl
  cat << .
    For info regarding the Icon programming language, please see
      https://www.cs.arizona.edu/icon

    The Icon Programing Library is at \${IPL}:
      ${IPL}

    For offline help for icon:
      man -l \$IPL/../man/man1/icon.1

    For offline help for icont and iconx:
      man -l \$IPL/../man/man1/icont.1

    To build loadable C functions, see:
      `readlink -f ${IPL}/../doc/condagcc.txt`
.
fi
' >> ${PREFIX}/etc/conda/activate.d/activate-icon.sh

# Create or append deactivation script to reset IPL envar
mkdir -p ${PREFIX}/etc/conda/deactivate.d
echo '#!/bin/sh
if [ -d ${CONDA_PREFIX}/icon/ipl ]; then
  if [ -z "${IPL_OLD}" ]; then
    unset IPL
  else
    export IPL=${IPL_OLD}
  fi
  unset IPL_OLD
fi
' >> ${PREFIX}/etc/conda/deactivate.d/deactivate-icon.sh

# Create instructions to make extension libraries in C
echo '
To build loadable C functions as described at
  https://www.cs.arizona.edu/icon/uguide/cfuncs.htm
you will need to add the C compiler and some tools to your environment, e.g.:
  conda install -c conda-forge gcc_linux-64 make sed binutils
  pushd ${CONDA_PREFIX}/icon/ipl/packs/loadfunc
  make CC=${CC}
  ls -l libdemo.so
  popd

Bug: Building with C++, e.g.,
  ${CONDA_PREFIX}/icon/ipl/packs/loadfuncpp
has not yet been successful in a conda environment.
It will be necessary but not sufficient to install gxx_linux-64.
' >> ${DEPLOY}/doc/condagcc.txt
