CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CXXFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
FFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

cmake -B build -S . \
      -DBLIS_CONFIG_FAMILY=amdzen \
      -DBUILD_STATIC_LIBS=OFF \
      -DENABLE_THREADING=openmp \
      -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build build --parallel ${CPU_COUNT}
cmake --install build

