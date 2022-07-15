#!/bin/bash

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

# Install futile
cd ../../futile
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
