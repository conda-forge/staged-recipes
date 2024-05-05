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

  ldd ${INSTALL_ROOT}/bin/sbcl > _ldd_bootstrapped_sbcl.txt
cd ${SRC_DIR}

cd ${SRC_DIR}/sbcl-from-source
  # Uses $INSTALL_ROOT to find bootstrapped SBCL
  sh make.sh --fancy --prefix=${SRC_DIR}/_from_source > _sbcl_compilation.txt 2>&1

  # Set the environment variables to install SBCL in $PREFIX
  # INSTALL_ROOT=${PREFIX} SBCL_HOME=${INSTALL_ROOT}/lib/sbcl sh install.sh

  INSTALL_ROOT=${SRC_DIR}/_installed SBCL_HOME=${INSTALL_ROOT}/lib/sbcl sh install.sh
  strip ${SRC_DIR}/_installed/bin/sbcl

  python ${RECIPE_DIR}/build_helpers/elf_reader.py -a ${SRC_DIR}/_installed/bin/sbcl > _sbcl_elf_info.txt 2>&1
  patchelf \
     --set-interpreter ${PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64/ld-2.28.so \
     --set-rpath ${PREFIX}/x86_64-conda-linux-gnu/sysroot/lib64 \
     --add-needed libzstd.so.1 \
     --add-needed libdl.so.2 \
     --add-needed libpthread.so.0 \
     --add-needed libm.so.6 \
     --add-needed libc.so.6 \
     ${SRC_DIR}/_installed/bin/sbcl

  ldd ${SRC_DIR}/_installed/bin/sbcl > _ldd_installed_sbcl.txt

  cp -r ${SRC_DIR}/_installed/lib ${PREFIX}
  cp -r ${SRC_DIR}/_installed/share ${PREFIX}
  cp -r ${SRC_DIR}/_installed/bin ${PREFIX}

  # This depends upon TeX, which does not seem to have a good toolset on conda-forge
  # cd ./doc/manual && make

  # cd ./tests && rm elfcore.test.sh futex-wait.test.sh && sh run-tests.sh > /dev/null 2>&1 && cd ..

  cp ./COPYING ${SRC_DIR}
cd ${SRC_DIR}

# Install SBCL in conda-forge environment
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/sbcl-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/sbcl-deactivate.sh
