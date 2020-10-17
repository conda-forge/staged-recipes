#!/bin/bash

sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert'/" ./manage_externals/manic/repository_svn.py
./manage_externals/checkout_externals

cp .config_files.xml  ${PREFIX}/

mkdir -p ${PREFIX}/bin
cp -r cime ${PREFIX}/
cp -r cime_config ${PREFIX}/
cp -r components ${PREFIX}/
cp -r src ${PREFIX}/
cp -r bld ${PREFIX}/

cd ${PREFIX}/bin/
ln -s ../cime/scripts/create_* .
ln -s ../cime/scripts/query_* .
