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
	..	


make -j${CPU_COUNT}
