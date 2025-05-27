set -ex
mkdir -p build
pushd build

export PREFIX=${PREFIX:-${CONDA_PREFIX}}

# I'm not really able to get the cli stuff to build....
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DPOSITION_INDEPENDENT_CODE=ON \
    -DDATOVIZ_WITH_CLI=OFF \
    ..

make -j${CPU_COUNT}
make install

popd

${PYTHON} utils/generate_cython.py
pushd bindings/cython
${PYTHON} -m pip install --no-deps --no-build-isolation .
popd
