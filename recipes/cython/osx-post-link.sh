#!/bin/bash

cd $PREFIX/lib
rm -f libgcc_s.10.5.dylib
ln -s /usr/lib/libgcc_s.1.dylib libgcc_s.10.5.dylib
