#!/usr/bin/env bash

set -ex

function bootstrap_sbcl() {
    local bootstrapping_dir=$1
    local build_prefix=$2
    local current_dir=$(pwd)

    PATH=${INSTALL_ROOT}/bin:$PATH

    cd ${bootstrapping_dir}

    # Install SBCL in $INSTALL_ROOT ($src_dir/_bootstrapped)
    ./install.sh

    # Bootstrapped SBCL is linked to GLIBC 2.35, but only needs 2.28
    patchelf \
        --set-interpreter ${build_prefix}/x86_64-conda-linux-gnu/sysroot/lib64/ld-${LIBC_CONDA_VERSION-2.28}.so \
        --set-rpath ${build_prefix}/x86_64-conda-linux-gnu/sysroot/lib64 \
        ${INSTALL_ROOT}/bin/sbcl

    ldd ${INSTALL_ROOT}/bin/sbcl > _ldd_bootstrapped_sbcl.txt
    cd ${current_dir}
}

# Once merged, use previous Conda version of SBCL to bootstrap the new version
# mamba install -y sbcl

export INSTALL_ROOT=${SRC_DIR}/_bootstrapped
export SBCL_HOME=${INSTALL_ROOT}/lib/sbcl
bootstrap_sbcl "${SRC_DIR}/bootstrapping" "${BUILD_PREFIX}"

# Define linker and 2.28 version of GLIBC
cd ${SRC_DIR}/sbcl-from-source
  # Uses $INSTALL_ROOT to find bootstrapped SBCL
  bash make.sh --fancy > _sbcl_compilation.txt 2>&1

  # Set the environment variables to install SBCL in $PREFIX
  INSTALL_ROOT=${PREFIX} SBCL_HOME=${INSTALL_ROOT}/lib/sbcl bash install.sh
  strip ${INSTALL_ROOT}/bin/sbcl

  #patchelf \
  #   --set-rpath \$PREFIX/x86_64-conda-linux-gnu/sysroot/lib64 \
  #   --add-needed libzstd.so.1 \
  #   --add-needed libdl.so.2 \
  #   --add-needed libpthread.so.0 \
  #   --add-needed libm.so.6 \
  #   --add-needed libc.so.6 \
  #   ${INSTALL_ROOT}/bin/sbcl
  patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 --remove-rpath ${INSTALL_ROOT}/bin/sbcl

  python ${RECIPE_DIR}/build_helpers/elf_reader.py -a --debug ${INSTALL_ROOT}/bin/sbcl > _sbcl_elf_info.txt 2>&1
  ldd ${INSTALL_ROOT}/bin/sbcl > _ldd_installed_sbcl.txt

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
