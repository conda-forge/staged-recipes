if [[ ${target_platform} == "osx-"* ]]; then
    ILASTIKTOOLS_CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
else
    ILASTIKTOOLS_CXXFLAGS="${CXXFLAGS} -std=c++11"
fi

CONFIGURATION="Release"

mkdir build
cd build
cmake ..\
    -G "Ninja" \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_CXX_FLAGS="${ILASTIKTOOLS_CXXFLAGS}" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPython_EXECUTABLE=${PYTHON} \
    -DWITH_OPENMP=ON \
##

cmake --build . --parallel ${CPU_COUNT}
cmake --build . --target install
