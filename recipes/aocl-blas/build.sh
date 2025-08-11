CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

cmake -B buildaoclutils -S aoclutils \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DAU_BUILD_STATIC_LIBS=OFF
cmake --build buildaoclutils --parallel ${CPU_COUNT}
cmake --install buildaoclutils

cmake -B buildaoclblas -S aoclblas \
      -DBLIS_CONFIG_FAMILY=amdzen \
      -DBUILD_STATIC_LIBS=OFF \
      -DENABLE_THREADING=openmp \
      -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build buildaoclblas --parallel ${CPU_COUNT}
cmake --install buildaoclblas

cmake -B buildaocllapack -S aocllapack \
      -DENABLE_AMD_FLAGS=ON \
      -DENABLE_AOCL_BLAS=ON \
      -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build buildaocllapack --parallel ${CPU_COUNT}
cmake --install buildaocllapack
