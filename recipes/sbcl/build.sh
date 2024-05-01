#!/bin/bash

set -ex

export LIBC_INTERPRETER=${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64/ld-2.28.so
export LIBC_RPATH="${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64:${BUILD_PREFIX}/lib64:${BUILD_PREFIX}/lib"

cd ${SRC_DIR}/bootstrapping
  export INSTALL_ROOT=${SRC_DIR}/_bootstrapped
  PATH=${INSTALL_ROOT}/bin:$PATH
  export SBCL_HOME=${INSTALL_ROOT}/lib/sbcl
  ./install.sh

  patchelf \
    --set-interpreter ${LIBC_INTERPRETER} \
    --set-rpath ${LIBC_RPATH} \
    ${INSTALL_ROOT}/bin/sbcl
cd ${SRC_DIR}

cd ${SRC_DIR}/sbcl-from-source
  sh make.sh --fancy --prefix=${SRC_DIR}/_from_source > _compilation.log
  INSTALL_ROOT=${SRC_DIR}/_installed SBCL_HOME=${INSTALL_ROOT}/lib/sbcl sh install.sh

  # This depends upon TeX, which does not seem to have a good toolset on conda-forge
  # cd ./doc/manual && make

  cd ./tests && rm elfcore.test.sh futex-wait.test.sh && sh run-tests.sh > _tests.log && cd ..

  cp ./COPYING ${SRC_DIR}
cd ${SRC_DIR}

ls -lR ${SRC_DIR}/_installed > _installed.log

# Install SBCL in conda-forge environment
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/sbcl-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/sbcl-deactivate.sh

cp -r ${SRC_DIR}/_installed/* ${PREFIX}/
