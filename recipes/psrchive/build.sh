#! /bin/bash

# Change to right C++ standard for psrchive:
export CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-std=\S+\s/-std=c++11 /')
echo "build.sh updated CXXFLAGS=${CXXFLAGS}"

# Remove library stripping option (MacOS)
export LDFLAGS=$(echo "$LDFLAGS" | sed 's/-Wl,-dead_strip_dylibs//')
echo "build.sh updated LDFLAGS=${LDFLAGS}"

./configure --prefix=$PREFIX --disable-local --enable-shared \
  --includedir=$PREFIX/include/psrchive --with-Qt-dir=no \
  PGPLOT_DIR=$PREFIX/include/pgplot
make -j${CPU_COUNT}
make install

# Set up PSRCHIVE environment variable
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/psrchive-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/psrchive-deactivate.sh
cp ${RECIPE_DIR}/scripts/activate.csh ${ACTIVATE_DIR}/psrchive-activate.csh
cp ${RECIPE_DIR}/scripts/deactivate.csh ${DEACTIVATE_DIR}/psrchive-deactivate.csh
