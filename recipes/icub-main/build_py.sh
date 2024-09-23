#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPython_EXECUTABLE:PATH=$PYTHON \
    -DCREATE_PYTHON:BOOL=ON \
    -DCREATE_RUBY:BOOL=OFF \
    -DCREATE_JAVA:BOOL=ON \
    -DCREATE_CSHARP:BOOL=ON \
    -DCMAKE_INSTALL_PYTHONDIR:PATH=${SP_DIR}

ninja -v
cmake --build . --config Release --target install
