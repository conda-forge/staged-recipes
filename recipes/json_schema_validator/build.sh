#! /bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=y . -Bbuilddir
make -C builddir/ install
