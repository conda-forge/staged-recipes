mkdir -p build_conda
cd build_conda
rm -f CMakeCache.txt

export TBB_LINK=${PREFIX}/lib
export EMBREE_LINK=${PREFIX}/lib

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DPYTHON_EXECUTABLE=${PYTHON} \
      -DENABLE_EMBREE=on \
      -DENABLE_TBB=on \
      -DENABLE_CUDA=off \
      -DENABLE_OPTIX=off

make install
