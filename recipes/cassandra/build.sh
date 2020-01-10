#!/bin/bash

cd ${SRC_DIR}

ls

cd Src/

make -f Makefile.conda

cp ../Scripts/Frag_Library_Setup/library_setup.py ${PREFIX}/bin/.
cp ../Scripts/MCF_Generation/mcfgen.py ${PREFIX}/bin/.


