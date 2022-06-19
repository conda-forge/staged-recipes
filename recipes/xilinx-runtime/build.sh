#!/bin/env/bash
set -e

mkdir -p $SRC_DIR/build-release

cmake \
  -S $SRC_DIR/src  \
  -B $SRC_DIR/build-release  \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_SKIP_INSTALL_RPATH=ON

cmake --build $SRC_DIR/build-release --parallel ${CPU_COUNT}

cmake --install $SRC_DIR/build-release

# XILINX_XRT
mkdir -p $PREFIX/etc/conda/activate.d
echo -e "#!/bin/env/bash\nexport XILINX_XRT=\$CONDA_PREFIX\n" > $PREFIX/etc/conda/activate.d/env_vars.sh
