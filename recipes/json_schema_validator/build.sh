#! /bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=y --DCMAKE_CXX_COMPILE_FEATURES=cxx_range_for . -Bbuilddir
make -C builddir/ install
