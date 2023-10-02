#!/bin/bash

echo "Step 1"
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
echo "Step 2"
yum -y update
echo "Step 3"
yum -y install gcc gcc-c++ make cmake postgresql13-devel proj-devel json-c-devel geos39-devel gsl-devel
echo "Step 4"
git clone https://github.com/estebanzimanyi/MobilityDB
echo "Step 5"

cd MobilityDB

git fetch
git checkout pymeos4
echo "Step 6"

cd build

cmake .. -DMEOS=on -DGEOS_INCLUDE_DIR=/usr/geos39/include/ -DGEOS_LIBRARY=/usr/geos39/lib64/libgeos_c.so
echo "Step 7"
make -j
echo "Step 8"
make install
echo "Step 9"

python -m pip install . -vv
echo "Step 10"