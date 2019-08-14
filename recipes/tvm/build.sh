set -e
set -u

mkdir -p build
pushd build

cmake   \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CONFIGURATION_TYPES="Release" \
	-DUSE_CUDA=OFF \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
 	-DCMAKE_PREFIX_PATH=${PREFIX} \
        -DDLPACK_PATH=${PREFIX}/include/dlpack \
	-DDMLC_CORE_PATH=${PREFIX}/lib \
	-DUSE_VULKAN=OFF \
	-DUSE_LLVM=$PREFIX/bin/llvm-config \
	-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross_compile.cmake \
	..


make -j${CPU_COUNT}
make install

popd

pushd python
$PYTHON setup.py install
popd

pushd topi/python
$PYTHON setup.py install
popd

pushd nnvm/python
$PYTHON setup.py install
popd
