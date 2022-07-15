#!/bin/bash

# Install futile
cd ../../futile
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install spred
cd spred
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install atlab
cd ../../atlab
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install chess
cd ../../chess
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install pseudo
cd ../../pseudo
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install psolver
cd ../../psolver
autoreconf --install
mkdir build
cd build
../configure
make
make install

# Install bigdft
cd ../../bigdft
autoreconf --install
mkdir build
cd build
../configure
make
make install
