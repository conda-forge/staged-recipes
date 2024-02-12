#!/bin/bash

mkdir build buildlibs
cd buildlibs
cmake -DCMAKE_BUILD_TYPE=Release     \
      -DVSP_USE_SYSTEM_LIBXML2=true  \
      -DVSP_USE_SYSTEM_FLTK=false    \
      -DVSP_USE_SYSTEM_GLM=true      \
      -DVSP_USE_SYSTEM_GLEW=true     \
      -DVSP_USE_SYSTEM_CMINPACK=true \
      -DVSP_USE_SYSTEM_LIBIGES=false \
      -DVSP_USE_SYSTEM_EIGEN=true    \
      -DVSP_USE_SYSTEM_CODEELI=false \
      -DVSP_USE_SYSTEM_CPPTEST=false \
      ../Libraries
make

cd ../build
cmake -DVSP_LIBRARY_PATH=../buildlibs \
      -DCMAKE_BUILD_TYPE=Release      \
      -DCMAKE_INSTALL_PREFIX=$PREFIX  \
      -DCMAKE_INSTALL_LIBDIR=lib      \
      -DVSP_ENABLE_MATLAB_API=OFF     \
      -DVSP_USE_SYSTEM_EIGEN=ON       \
      -DVSP_USE_SYSTEM_FLTK=OFF       \
      -DVSP_USE_SYSTEM_GLEW=ON        \
      -DVSP_USE_SYSTEM_LIBXML2=ON     \
      ../src/

make package
