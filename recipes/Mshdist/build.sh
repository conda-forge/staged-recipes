set -e
sed -i 's/"-w -O3"/"\$ENV{CFLAGS} -w -O3"/g' CMakeLists.txt
#echo CFLAGS=$CFLAGS
echo 'message(STATUS "CMAKE_C_FLAGS=${CMAKE_C_FLAGS}")' >> CMakeLists.txt
#echo 'message(STATUS "CFLAGS=${CFLAGS}")' >> CMakeLists.txt
#echo 'message(STATUS "ENV{CFLAGS}=$ENV{CFLAGS}")' >> CMakeLists.txt
#echo 'message(STATUS "CMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}")' >> CMakeLists.txt
#cat CMakeLists.txt
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_SKIP_BUILD_RPATH=TRUE
#make VERBOSE=1
make install
