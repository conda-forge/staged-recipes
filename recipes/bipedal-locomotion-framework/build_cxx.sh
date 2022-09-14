#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DFRAMEWORK_USE_YARP:BOOL=ON \
    -DFRAMEWORK_USE_OsqpEigen:BOOL=ON \
    -DFRAMEWORK_USE_matioCpp:BOOL=ON \
    -DFRAMEWORK_USE_manif:BOOL=ON \
    -DFRAMEWORK_USE_Qhull:BOOL=ON \
    -DFRAMEWORK_USE_cppad:BOOL=ON \
    -DFRAMEWORK_USE_casadi:BOOL=ON \
    -DFRAMEWORK_USE_LieGroupControllers:BOOL=ON \
    -DFRAMEWORK_USE_UnicyclePlanner:BOOL=ON \
    -DFRAMEWORK_COMPILE_PYTHON_BINDINGS:BOOL=OFF

cat CMakeCache.txt

cmake --build . --config Release
cmake --build . --config Release --target install

ctest --output-on-failure -C Release
