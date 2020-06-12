#!/bin/bash

cd opensim-core-source
cd ..
mkdir build_dep
cd build_dep
cmake ../opensim-core-source/dependencies -LAH \
    -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE="Release" \
    -DSUPERBUILD_simbody=OFF \
    -DSUPERBUILD_BTK=OFF \
    -DSUPERBUILD_docopt=ON \
    -DCMAKE_INSTALL_PREFIX=../opensim_dependencies_install \
    -DCMAKE_INSTALL_LIBDIR="lib"
make --jobs ${CPU_COUNT}

# On Linux, docopt libraries are installed into lib64 but should be installed
# into lib.
cd docopt/build
cmake . -DCMAKE_INSTALL_LIBDIR="lib"
make --jobs ${CPU_COUNT} install
cd ../..

cp ../opensim-core-source/dependencies/docopt/LICENSE-MIT ../opensim-core-source/docopt.cpp_LICENSE-MIT

cd ..
mkdir build
cd build
cmake ../opensim-core-source -LAH \
    -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE="Release" \
    -DOPENSIM_DEPENDENCIES_DIR=../opensim_dependencies_install \
    -Ddocopt_DIR="${SRC_DIR}/opensim_dependencies_install/docopt/lib/cmake/docopt" \
    -DSIMBODY_HOME="${PREFIX}" \
    -DBUILD_PYTHON_WRAPPING=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="lib" 
make --jobs ${CPU_COUNT}
make doxygen
make install

