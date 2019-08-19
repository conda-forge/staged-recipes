#!/bin/bash

mkdir -p build
cd build

# temporary workaround for vtk-cmake setup
find ${PREFIX}/lib/cmake/vtk-8.2/ -type f -print0 | xargs -0 \
    sed -i 's#/home/conda/feedstock_root/build_artifacts/vtk_.*_build_env/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib.*;##g'
# find ${PREFIX}/lib/cmake/vtk-8.2/ -type f -print0 | xargs -0 \
#     sed -i 's#/usr/lib64/#\$PREFIX/lib/#g'

cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DTTK_BUILD_VTK_WRAPPERS=ON \
    -DTTK_BUILD_VTK_PYTHON_MODULE=ON \
    -DTTK_BUILD_PARAVIEW_PLUGINS=OFF \
    -DTTK_BUILD_STANDALONE_APPS=OFF \
    -DTTK_ENABLE_KAMIKAZE=OFF \
    -DTTK_ENABLE_MPI=OFF \
    -DTTK_ENABLE_OPENMP=ON

# -DBoost_NO_BOOST_CMAKE:BOOL=ON

ninja install -v
