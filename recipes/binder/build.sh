mkdir -p build

pushd build

cmake   -G Ninja \
	-DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_PREFIX_PATH=${PREFIX} \
	-DLLVM_ENABLE_EH=0 \
	-DLLVM_ENABLE_RTTI=OFF \
	../source 

ninja

ninja install

popd

#pushd source

#${PYTHON} build.py -j${CPU_COUNT} --type="Release" --compiler="gcc" --pybind11=$SP_DIR/pybind11 --binder .
