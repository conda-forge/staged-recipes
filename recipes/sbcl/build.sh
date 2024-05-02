#!/bin/bash

set -ex

cd ${SRC_DIR}/bootstrapping
  export INSTALL_ROOT=${SRC_DIR}/_bootstrapped
  PATH=${INSTALL_ROOT}/bin:$PATH
  export SBCL_HOME=${INSTALL_ROOT}/lib/sbcl

  # Install SBCL in $INSTALL_ROOT ($SRC_DIR/_bootstrapped)
  ./install.sh

  # Bootstrapped SBCL is linked to GLIBC 2.35, but only needs 2.28
  patchelf \
    --set-interpreter ${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64/ld-2.28.so \
    --set-rpath ${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64 \
    ${INSTALL_ROOT}/bin/sbcl
cd ${SRC_DIR}

cd ${SRC_DIR}/sbcl-from-source
  # Uses $INSTALL_ROOT to find bootstrapped SBCL
  sh make.sh --fancy --prefix=${SRC_DIR}/_from_source > _compilation.log

  # Set the environment variables to install SBCL in $PREFIX
  INSTALL_ROOT=${PREFIX} SBCL_HOME=${INSTALL_ROOT}/lib/sbcl sh install.sh

  # This depends upon TeX, which does not seem to have a good toolset on conda-forge
  # cd ./doc/manual && make

  cd ./tests && rm elfcore.test.sh futex-wait.test.sh && sh run-tests.sh > _tests.log && cd ..

  cp ./COPYING ${SRC_DIR}
cd ${SRC_DIR}

# Install SBCL in conda-forge environment
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/sbcl-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/sbcl-deactivate.sh
