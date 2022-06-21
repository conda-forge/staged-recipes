#!/bin/bash

target=${PREFIX}/opt/snap
mkdir -p $target/.snap
mkdir -p ${PREFIX}/opt/snap-src

cp -r $SRC_DIR/* ${PREFIX}/opt/snap-src



echo "Build JPY"  &>> ${PREFIX}/.messages.txt
# python3 -m pip install --upgrade pip wheel
echo "cd to JPY"  &>> ${PREFIX}/.messages.txt

# Build jpy wheel for snap
cd ${PREFIX}/opt/snap-src/jpy
python setup.py bdist_wheel

cd ${PREFIX}

# retrieving jpy wheel to copy in ${SNAP_USER}/snap-python/snappy directory
mkdir -p ${PREFIX}/opt/snap-src/jpy_wheel
cp -v $( find ${PREFIX}/opt/snap-src/jpy -name "jpy*.whl" ) ${PREFIX}/opt/snap-src/jpy_wheel

echo "list files in ${PREFIX}/opt/snap-src/jpy_wheel"  &>> ${PREFIX}/.messages.txt
ls -l ${PREFIX}/opt/snap-src/jpy_whee &>> ${PREFIX}/.messages.txt