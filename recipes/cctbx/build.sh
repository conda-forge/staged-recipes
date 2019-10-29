#!/bin/bash

# reorganize directories
mkdir modules
mv cctbx_project modules
ln -s modules/cctbx_project/libtbx/auto_build/bootstrap.py

# download more sources from cctbx GitHub organization
cd modules
git clone https://github.com/cctbx/annlib.git
git clone https://github.com/cctbx/annlib_adaptbx.git
git clone https://github.com/cctbx/ccp4io.git
git clone https://github.com/cctbx/ccp4io_adaptbx.git
git clone https://github.com/cctbx/gui_resources.git
git clone https://github.com/cctbx/tntbx.git
cd ..

# build
python bootstrap.py build --builder=cctbxlite --use-conda $PREFIX --nproc $CPU_COUNT
