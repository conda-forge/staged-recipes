#!/bin/env/bash
set -e

# Hack so ensure that the correct
# version info is printed
export XRT_VERSION_PATCH=466

mkdir -p $SRC_DIR/build-release

cmake \
  $CMAKE_ARGS \
  -S $SRC_DIR/src  \
  -B $SRC_DIR/build-release  \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SKIP_INSTALL_RPATH=ON \
  -DXRT_STATIC_COMPONENT=xrt-static

cmake --build $SRC_DIR/build-release --parallel ${CPU_COUNT}

cmake --install $SRC_DIR/build-release --component xrt

# XILINX_XRT
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
echo -e "#!/bin/env/bash\nexport XILINX_XRT=\$CONDA_PREFIX\n" > $PREFIX/etc/conda/activate.d/${PKG_NAME}_activate.sh
echo -e "#!/bin/env/bash\nunset XILINX_XRT\n" > $PREFIX/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh
