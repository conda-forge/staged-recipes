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
       --config-flags="--compiler=conda" --config-flags="--use_environment_flags" \
       --config-flags="--enable_cxx11" --config-flags="--no_bin_python"

# fix rpath on macOS because libraries and extensions will be in different locations
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  echo Fixing rpath:
  python $RECIPE_DIR/fix_macos_rpath.py
fi

# copy Python files
echo Copying Python files
./build/bin/libtbx.python $RECIPE_DIR/create_setup.py --version $PKG_VERSION
cd modules/cctbx_project
python cctbx_setup.py install
cd ../..

# copy bin
echo Copying dispatchers
if [ -f build/bin/python ]; then
  rm build/bin/python
fi
cp -a build/bin/* $PREFIX/bin
cp -a build/exe_dev/* $PREFIX/bin

# copy include
echo Copying headers
cp -a build/include/* $PREFIX/include

# copy lib
echo Copying libraries
cp -a build/lib/lib* $PREFIX/lib/
cp -a build/lib/*_ext.* $STDLIB_DIR/lib-dynload

# copy libccp4 data
LIBCCP4_DATA_DIR=$PREFIX/share/libccp4/data
mkdir -p $LIBCCP4_DATA_DIR
cp -a modules/ccp4io/libccp4/data/*.lib $LIBCCP4_DATA_DIR

# copy libtbx_env and fixing script
echo Copying libtbx_env
cp -a build/libtbx_env $PREFIX/libtbx_env
EXTRA_CCTBX_DIR=$PREFIX/share/cctbx
mkdir -p $EXTRA_CCTBX_DIR
cp -a $RECIPE_DIR/fix_libtbx_env.py $EXTRA_CCTBX_DIR/fix_libtbx_env.py

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${RECIPE_DIR}/${CHANGE}.csh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.csh"
done
