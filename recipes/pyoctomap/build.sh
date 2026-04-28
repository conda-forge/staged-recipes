#!/bin/bash
set -ex

# Replace the partial src/octomap with the full source
rm -rf src/octomap
mv octomap_repo src/octomap

# Build OctoMap directly instead of using the CI script
# This is more robust for Conda and handles CMAKE_ARGS correctly
mkdir -p src/octomap/build
cd src/octomap/build

cmake ${CMAKE_ARGS} .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_OCTOVIS_SUBPROJECT=OFF \
    -DBUILD_DYNAMICETD3D_SUBPROJECT=ON \
    -DBUILD_TESTING=OFF

cmake --build . --target install -j${CPU_COUNT}

# Stage the libraries for the Python extension build.
# pyoctomap's build process expects them in src/octomap/lib
cd ../../..
mkdir -p src/octomap/lib
if [ "$(uname -s)" == "Darwin" ]; then
    cp -v ${PREFIX}/lib/liboctomap*.dylib src/octomap/lib/
    cp -v ${PREFIX}/lib/liboctomath*.dylib src/octomap/lib/
    cp -v ${PREFIX}/lib/libdynamicedt3d*.dylib src/octomap/lib/
else
    cp -v ${PREFIX}/lib/liboctomap.so* src/octomap/lib/
    cp -v ${PREFIX}/lib/liboctomath.so* src/octomap/lib/
    cp -v ${PREFIX}/lib/libdynamicedt3d.so* src/octomap/lib/
fi

# Install the Python package
${PYTHON} -m pip install . -vv
