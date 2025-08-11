CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

cmake -B buildaocllapack -S aocllapack \
      -DENABLE_AMD_FLAGS=ON \
      -DENABLE_AOCL_BLAS=ON \
      -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build buildaocllapack --parallel ${CPU_COUNT}
cmake --install buildaocllapack
