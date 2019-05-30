mkdir build -p
cd build 

cmake -G "Ninja" \
	  -D CMAKE_BUILD_TYPE:STRING=Release \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D USE_PY_3:BOOL=ON \
      -D BUILD_PY_LIB:BOOL=ON \
      ..

ninja install