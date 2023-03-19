set -e

sed -i 's/DESTINATION "$ENV{HOME}/DESTINATION "${CMAKE_INSTALL_PREFIX}/' CMakeLists.txt
sed -i 's/$ENV{HOME}\/include/$ENV{BUILD_PREFIX}\/include/' CMakeLists.txt
sed -i 's/HINTS "$ENV{HOME}\/lib"/HINTS "$ENV{PREFIX}\/lib"/' CMakeLists.txt
sed -i 's/"-w -O3"/"\$ENV{CFLAGS} -w -O3"/' CMakeLists.txt
#sed -i 's/set_target_properties( mshdist PROPERTIES INSTALL_RPATH/#/' CMakeLists.txt
#sed -i 's/set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)/#/' CMakeLists.txt

cat -n CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -S . -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose

ldd $PREFIX/lib/libMshdist.so
ldd $PREFIX/bin/mshdist