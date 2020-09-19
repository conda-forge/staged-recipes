#!/bin/bash

# link bootstrap.py
ln -s modules/cctbx_project/libtbx/auto_build/bootstrap.py

# copy LICENSE.txt to root
cp modules/cctbx_project/LICENSE.txt .

# remove extra source code
rm -fr ./modules/boost
rm -fr ./modules/eigen
rm -fr ./modules/scons

# build
${PYTHON} bootstrap.py build --builder=cctbx --use-conda ${PREFIX} --nproc ${CPU_COUNT} \
  --config-flags="--compiler=conda" --config-flags="--use_environment_flags" \
  --config-flags="--enable_cxx11" --config-flags="--no_bin_python" \
  --config-flags="--skip_phenix_dispatchers"
cd build
./bin/libtbx.configure cma_es crys3d fable rstbx spotinder
./bin/libtbx.scons -j ${CPU_COUNT}
./bin/libtbx.scons -j ${CPU_COUNT}
cd ..

# remove dxtbx and cbflib
rm -fr ./build/*dxtbx*
rm -fr ./build/*cbflib*
rm -fr ./build/lib/dxtbx*
rm -fr ./build/lib/cbflib*
rm -fr ./modules/dxtbx
rm -fr ./modules/cbflib
./build/bin/libtbx.python ${RECIPE_DIR}/clean_env.py

# remove extra source files (C, C++, Fortran, CUDA)
cd build
find . -name "*.c" -type f -delete
find . -name "*.cpp" -type f -delete
find . -name "*.cu" -type f -delete
find . -name "*.f" -type f -delete
cd ../modules
find . -name "*.c" -type f -delete
find . -name "*.cpp" -type f -delete
find . -name "*.cu" -type f -delete
find . -name "*.f" -type f -delete
cd ..

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
${PYTHON} ${CCTBX_CONDA_BUILD}/update_libtbx_env.py
