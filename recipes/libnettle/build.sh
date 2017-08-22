#!/bin/bash



./configure --prefix="${PREFIX}" 
            
make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
