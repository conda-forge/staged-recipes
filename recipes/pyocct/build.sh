mkdir -p build
cd build

#  for local debugging
# -D CMAKE_C_COMPILER=/usr/bin/gcc \
# -D CMAKE_CXX_COMPILER=/usr/bin/g++ \

cmake -G "Ninja" \
	  -D CMAKE_BUILD_TYPE=Release \
      -D PTHREAD_INCLUDE_DIRS=${PREFIX} \
      -D ENABLE_SMESH=ON \
      -D ENABLE_NETGEN=ON \
      -D ENABLE_BLSURF=OFF \
      ..

ninja install

cd ..
${PYTHON} setup.py install
