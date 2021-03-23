#!/bin/bash

export JAVA_HOME="${PREFIX}"

./build.sh dist
cd apache-ant-${PKG_VERSION}

for i in etc lib bin; do
  mkdir -p "${PREFIX}/$i"
  cp -rv $i/* "${PREFIX}/$i"
done

# ensure that ANT_HOME is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export ANT_HOME_CONDA_BACKUP=$ANT_HOME' > "$PREFIX/etc/conda/activate.d/ant_home.sh"
echo 'export ANT_HOME=$CONDA_PREFIX' >> "$PREFIX/etc/conda/activate.d/ant_home.sh"
mkdir -p $PREFIX/etc/conda/deactivate.d
echo 'export ANT_HOME=$ANT_HOME_CONDA_BACKUP' > "$PREFIX/etc/conda/deactivate.d/ant_home.sh"
