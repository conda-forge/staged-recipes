mkdir build -p
cd build 


CXX_FLAGS=${CXX_FLAGS}:-Wpedantic

cmake -G "Ninja" \
      -D CMAKE_BUILD_TYPE:STRING=Release \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D BUILD_PY_LIB:BOOL=ON \
      -D USE_PY_3:BOOL=ON \
      -D Boost_NO_BOOST_CMAKE:BOOL=ON \
      -D CMAKE_CXX_FLAGS:STRING="${CXX_FLAGS} -Wpedantic" \
      ../src

ninja install