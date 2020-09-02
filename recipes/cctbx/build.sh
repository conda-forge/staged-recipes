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
git clone https://github.com/yayahjb/cbflib.git  # remove
git clone https://github.com/cctbx/ccp4io.git
git clone https://github.com/cctbx/ccp4io_adaptbx.git
git clone https://github.com/cctbx/dxtbx.git  # remove
git clone https://github.com/cctbx/gui_resources.git
git clone https://github.com/cctbx/tntbx.git

cd annlib_adaptbx
git checkout conda
cd ..
cd ccp4io_adaptbx
git checkout conda
cd ..
cd dxtbx
git checkout libpath
cd ..

cd ..

# fix for setuptools
export SETUPTOOLS_USE_DISTUTILS=stdlib

# build
export CPU_COUNT=64
${PYTHON} bootstrap.py build --builder=cctbx --use-conda ${PREFIX} --nproc ${CPU_COUNT} \
  --config-flags="--compiler=conda" --config-flags="--use_environment_flags" \
  --config-flags="--enable_cxx11" --config-flags="--no_bin_python"
cd build
./bin/libtbx.configure cma_es fable rstbx spotinder
./bin/libtbx.scons -j ${CPU_COUNT}
./bin/libtbx.scons -j ${CPU_COUNT}
cd ..

# remove dxtbx and cbflib
rm -fr ./build/*dxtbx*
rm -fr ./build/*cbflib*
rm -fr ./lib/*dxtbx*
rm -fr ./lib/*cbflib*
rm -fr ./modules/*dxtbx*
rm -fr ./modules/*cbflib*
./build/bin/libtbx.python ${RECIPE_DIR}/clean_env.py

# remove intermediate objects in build directory
cd build
find . -name "*.o" -type f -delete
cd ..

# fix rpath on macOS because libraries and extensions will be in different locations
if [[ ! -z "$MACOSX_DEPLOYMENT_TARGET" ]]; then
  echo Fixing rpath:
  ${PYTHON} ${RECIPE_DIR}/fix_macos_rpath.py
fi

# copy files in build
echo Copying build
EXTRA_CCTBX_DIR=${PREFIX}/share/cctbx
mkdir -p ${EXTRA_CCTBX_DIR}
CCTBX_CONDA_BUILD=./modules/cctbx_project/libtbx/auto_build/conda_build
./build/bin/libtbx.python ${CCTBX_CONDA_BUILD}/install_build.py

# copy libtbx_env and update dispatchers
echo Copying libtbx_env
./build/bin/libtbx.python ${CCTBX_CONDA_BUILD}/update_libtbx_env.py
python ${CCTBX_CONDA_BUILD}/update_libtbx_env.py
