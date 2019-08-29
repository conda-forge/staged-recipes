#!/bin/bash

#mkdir -p ${PREFIX}/bin
#mkdir -p ${PREFIX}/lib

make all_test CC=$CC CXX=$CXX

#sed -i "s|#! /bin/sh|#!/bin/bash|" install.sh
sed -i.bak "s|DEST_HOME=.*|DEST_HOME=$PREFIX|" install.sh
bash ./install.sh

rm -r ${PREFIX}/man
rm -r ${PREFIX}/share

