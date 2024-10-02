
mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake \
    ${CMAKE_ARGS} \
    -G "Ninja" \
    -D UPDATE_DEPS=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    ${SRC_DIR}

cmake --build . --config Release
cmake --build . --config Release --target install
