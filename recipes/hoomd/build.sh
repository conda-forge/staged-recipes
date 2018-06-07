mkdir -p build-conda
cd build-conda
rm -rf ./*

export TBB_LINK=${PREFIX}/lib
export TBB_INC=${PREFIX}/include

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DPYTHON_EXECUTABLE=${PYTHON} \
      -DENABLE_MPI=off \
      -DENABLE_CUDA=off \
      -DBUILD_TESTING=off \
      -DENABLE_TBB=on \
      -DBUILD_JIT=on \
      -DMKL_LIBRARIES=""

make install
