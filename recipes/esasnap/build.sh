#!/bin/bash

target=$PREFIX/opt/snap
mkdir -p $target/.snap
mkdir -p $PREFIX/opt/snap-src

cp -r $SRC_DIR/* $PREFIX/opt/snap-src



echo "Build JPY"  &>> $PREFIX/.messages.txt
# python3 -m pip install --upgrade pip wheel
echo "cd to JPY"  &>> $PREFIX/.messages.txt
ls -l ${SNAP_HOME}/../snap-src/jpy &>> $PREFIX/.messages.txt
cd ${SNAP_HOME}/../snap-src/jpy
python setup.py bdist_wheel

cd ${PREFIX}

# retrieving jpy wheel to copy in ${SNAP_USER}/snap-python/snappy directory
jpy_file=$(find ${SNAP_HOME}/../snap-src/jpy -name "jpy-*.whl")
if [ -z "$jpy_file" ]
then
	echo "Jpy has not been installed correctly" &>> $PREFIX/.messages.txt
	exit 1
fi

jpy_filename=$(basename $jpy_file)


cp jpy_file ${SNAP_HOME}/../snap-src/


echo "list files in ls -l ${SNAP_HOME}/../snap-src/jpy" &>> $PREFIX/.messages.txt
ls -l ${SNAP_HOME}/../snap-src/jpy&>> $PREFIX/.messages.txt


echo "list files in ls -l ${SNAP_HOME}/../snap-src/" &>> $PREFIX/.messages.txt
ls -l ${SNAP_HOME}/../snap-src/&>> $PREFIX/.messages.txt
# pip install ${jpy_file}