set -euxo pipefail

rm -rf build || true
mkdir -p build
cd build

cmake ${SRC_DIR}/src ${CMAKE_ARGS} \
    -DBUILD_MESHLAB_MINI=ON \
    -DUSE_DEFAULT_BUILD_AND_INSTALL_DIRS=OFF \
    -DMESHLAB_BIN_INSTALL_DIR=${PREFIX}/bin \
    -DMESHLAB_LIB_INSTALL_DIR=${PREFIX}/lib \
    -DMESHLAB_PLUGIN_INSTALL_DIR=${PREFIX}/share/meshlab/plugins
    -DMESHLAB_SHADER_INSTALL_DIR=${PREFIX}/share/meshlab/shaders

make
make install
