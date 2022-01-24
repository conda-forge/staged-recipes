#!/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
   export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
   if [[ "$target_platform" == "osx-arm64" ]]; then
       cp config/distribution/darwin_cpu.cmake config.cmake
   else
       cp config/distribution/darwin_cpu_mkl.cmake config.cmake
       export MKL_INCLUDE_DIR=${CONDA_PREFIX}/include
   fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
       # if want to add mkl to cuda builds:
       CMAKE_ARGS_BLAS=-DUSE_BLAS='mkl'
       export MKL_INCLUDE_DIR=${CONDA_PREFIX}/include
   if [[ "$cuda_compiler_version" == "None" ]]; then
       cp config/distribution/linux_cpu_mkl.cmake config.cmake
   elif [[ $cuda_compiler_version == 11.0 ]]; then
       cp config/distribution/linux_cu110.cmake config.cmake
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64/stubs
   elif [[ $cuda_compiler_version == 11.2 ]]; then
       cp config/distribution/linux_cu112.cmake config.cmake  
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64/stubs
       # setting LD_LIBRARY_PATH to potential fix future cuda builds. 
       # Details from CI runs (limited to 6 hours):
       # - run fails around 90% through cmake with around 5.5 hours
       # - complains about not finding `libnvidia-ml.so.1`
       # - we have `libnvidia-ml.so` in /usr/local/cuda/lib64/stubs
       # - we could maybe make symlink here too?
   fi
fi

rm -rf build; mkdir build && cd build

cmake \
       -DCMAKE_PREFIX_PATH=$PREFIX \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_LIBDIR="lib" \
       -DCMAKE_INSTALL_PREFIX=$PREFIX \
       -DCMAKE_INCLUDE_PATH=$PREFIX/include \
       -DUSE_CPP_PACKAGE=ON \
       -DUSE_OPENMP=ON \
       -DBLA_STATIC=OFF \
       -DBUILD_SHARED_LIBS=ON \
       ${CMAKE_ARGS_BLAS} \
       ${CMAKE_ARGS} \
..

make -j ${CPU_COUNT}
make install

cd ../python
# ${PYTHON} setup.py install

if [[ "$OSTYPE" == "darwin"* ]]; then
    export MXNET_LIBRARY_PATH=${PREFIX}/lib/libmxnet.dylib
else
    export MXNET_LIBRARY_PATH=${PREFIX}/lib/libmxnet.so
fi

export MXNET_INCLUDE_PATH=${PREFIX}/include/mxnet

${PYTHON} -m pip install . -vv

#
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     ln ${PREFIX}/lib/libmxnet.dylib $SP_DIR/mxnet/libmxnet.dylib
#     find ${PREFIX} | grep libmxnet.dylib | grep -v $PREFIX/lib/libmxnet.dylib | xargs rm -f
#
# else
#     ln ${PREFIX}/lib/libmxnet.so $SP_DIR/mxnet/libmxnet.so
#     find ${PREFIX} | grep libmxnet.so | grep -v $PREFIX/lib/libmxnet.so | xargs rm -f
#
# fi
#

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
