#!/bin/bash

cd build

if [ "$(uname)" == "Darwin" ]; then

    cmake .. -Dall=ON -Dkrb5=OFF -Dcocoa=ON -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON -DBUILD_SHARED_LIBS=ON\
             -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root \
             -Dopengl=OFF -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
             -DCMAKE_FIND_ROOT_PATH=${PREFIX} -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib:${PREFIX}/lib/root" \
             -DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wl,-rpath,${PREFIX}/lib:${PREFIX}/lib/root" \
             -DCMAKE_C_FLAGS="${CFLAGS} -Wl,-rpath,${PREFIX}/lib:${PREFIX}/lib/root"

else
    
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++
    
    cmake .. -Dall=ON -Dkrb5=OFF -Dgnuinstall=ON -Drpath=ON -Dsoversion=ON \
             -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_SYSCONFDIR=${PREFIX}/etc/root -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
             -Dopengl=OFF -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} \
             -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib:${PREFIX}/lib/root" \
             -DCMAKE_CXX_FLAGS="-Wl,-rpath-link,${PREFIX}/lib:${PREFIX}/lib/root"

fi

# For some reason, CMAKE does not put "-I${PREFIX}/include" in the command line
# when compiling, with of course disastrous results...
ln -s $PREFIX/include/* include/

cmake --build . --target install -- -j ${CPU_COUNT}

# Install pyROOT in the site-packages so there is no need for
# setting PYTHONPATH
cp ${PREFIX}/lib/root/libPyROOT.* ${PREFIX}/lib/python2.7/site-packages/
cp ${PREFIX}/lib/root/ROOT.py ${PREFIX}/lib/python2.7/site-packages/
