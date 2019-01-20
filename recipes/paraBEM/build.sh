mkdir -p build
cd build
cmake .. -G "Ninja" \
      -DCMAKE_INSTALL_PREFIX:FILEPATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release # \
      # -DCMAKE_CXX_FLAGS="-std=c++11 -fPIC"

# add last 2 lines to cmake of paraBEM

ninja install
