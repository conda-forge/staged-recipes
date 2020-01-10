#!/bin/bash

cd ${SRC_DIR}

tar -xvf Cassandra*tar.gz

cd Cassandra_V*/Src/

make -f Makefile.conda

cp ../Scripts/Frag_Library_Setup/library_setup.py ${PREFIX}/bin/.
cp ../Scripts/MCF_Generation/mcfgen.py ${PREFIX}/bin/.

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

