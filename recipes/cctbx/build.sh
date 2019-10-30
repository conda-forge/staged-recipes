#!/bin/bash

# reorganize directories
cd ..
mv work cctbx_project
mkdir -p work/modules
mv cctbx_project work/modules/
cd work
ln -s modules/cctbx_project/libtbx/auto_build/bootstrap.py

# download more sources from cctbx GitHub organization
# replace with full source tarball
cd modules
git clone https://github.com/cctbx/annlib.git
git clone https://github.com/cctbx/annlib_adaptbx.git
git clone https://github.com/cctbx/ccp4io.git
git clone https://github.com/cctbx/ccp4io_adaptbx.git
git clone https://github.com/cctbx/gui_resources.git
git clone https://github.com/cctbx/tntbx.git
cd ..

# build
python bootstrap.py build --builder=cctbxlite --use-conda $PREFIX --nproc $CPU_COUNT \
       --config-flags="--compiler=conda" --config-flags="--use_environment_flags"

# copy Python files
./build/bin/libtbx.python $RECIPE_DIR/create_setup.py --version $PKG_VERSION
cd modules/cctbx_project
python cctbx_setup.py install
cd ../..

# copy bin
cp -a build/bin/* $PREFIX/bin

# copy include
cp -a build/include/* $PREFIX/include

# copy lib
cp -a build/lib/lib* $PREFIX/lib/
cp -a build/lib/*_ext.* $STDLIB_DIR

# fix libtbx_env
