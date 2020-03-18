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
${PYTHON} bootstrap.py build --builder=cctbxlite --use-conda ${PREFIX} --nproc ${CPU_COUNT} \
  --config-flags="--compiler=conda" --config-flags="--use_environment_flags" \
  --config-flags="--enable_cxx11" --config-flags="--no_bin_python"

# fix rpath on macOS because libraries and extensions will be in different locations
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  echo Fixing rpath:
  ${PYTHON} $RECIPE_DIR/fix_macos_rpath.py
fi

# copy files in build
CCTBX_CONDA_BUILD=./modules/cctbx_project/libtbx/auto_build/conda_build
./build/bin/libtbx.python ${CCTBX_CONDA_BUILD}/install_build.py

# copy libtbx_env and fixing script
echo Copying libtbx_env
./build/bin/libtbx.python ${CCTBX_CONDA_BUILD}/update_libtbx_env.py
EXTRA_CCTBX_DIR=${PREFIX}/share/cctbx
mkdir -p ${EXTRA_CCTBX_DIR}
cp -a ${CCTBX_CONDA_BUILD}/update_libtbx_env.py ${EXTRA_CCTBX_DIR}/update_libtbx_env.py
