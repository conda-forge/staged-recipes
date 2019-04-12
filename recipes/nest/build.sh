#!/bin/sh

export MPI_FLAGS=--allow-run-as-root

if [ $(uname) == Linux ]; then
    export MPI_FLAGS="$MPI_FLAGS;-mca;plm;isolated"
fi

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -Dwith-mpi=ON \
      -Dwith-openmp=ON \
      -Dwith-python=3 \
      -Dwith-gsl=$PREFIX \
      -DREADLINE_ROOT_DIR=$PREFIX \
      -DLTDL_ROOT_DIR=$PREFIX \
      ..
make -j2
make install

cp $PREFIX/lib64/* $PREFIX/lib -r

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done