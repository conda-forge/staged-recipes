mkdir build
cd build
cmake .. \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DBML_OPENMP="yes" \
  -DBML_MPI="no" \
  -DBML_COMPLEX="yes" \
  -DBML_TESTING="no" \
  -DBML_VALGRIND="no" \
  -DBML_COVERAGE="no" \
  -DBML_GPU="no" \
  -DBML_CUDA="no" \
  -DBML_MAGMA="no" \
  -DCUDA_TOOLKIT_ROOT_DIR="${CUDA_TOOLKIT_ROOT_DIR}" 
make -j${NUM_CPUS}
make install 
