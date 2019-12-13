mkdir build
cd build
cmake .. \
   -DCMAKE_BUILD_TYPE="Release" \
   -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
   -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
   -DBML_OPENMP="yes" \
   -DPROGRESS_OPENMP="yes" \
   -DPROGRESS_MPI="no" \
   -DBUILD_SHARED_LIBS="no" \
   -DPROGRESS_TESTING="no" \
   -DPROGRESS_EXAMPLES="no" \
   -DPROGRESS_GRAPHLIB="no"
make -j${NUM_CPUS}
make install 
