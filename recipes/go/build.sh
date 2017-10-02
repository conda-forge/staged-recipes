#!/bin/bash

# Move the go directory into $PREFIX/ so it can be built in its install location.
cd .. && mv go $PREFIX/ && cd $PREFIX/go

# Change to `src` build and then move out.
cd src
./all.bash
cd ..

# Delete `test` directory as it is no longer needed.
rm -rf test

# Link binaries.
mkdir -p $PREFIX/bin
ln -s $PREFIX/go/bin/go $PREFIX/bin/go
ln -s $PREFIX/go/bin/gofmt $PREFIX/bin/gofmt

# Install [de]activate scripts.

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
