#!/bin/bash

echo "######## env ############"
env
echo "#########################"

export DESTDIR=$PREFIX/include
make
make install

