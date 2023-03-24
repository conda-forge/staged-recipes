set -e

sed -i'.bkp' -e 's/DESTINATION "$ENV{HOME}/DESTINATION "${CMAKE_INSTALL_PREFIX}/' CMakeLists.txt
sed -i'.bkp' -e 's/$ENV{HOME}\/include/$ENV{BUILD_PREFIX}\/include/' CMakeLists.txt
sed -i'.bkp' -e 's/HINTS "$ENV{HOME}\/lib"/HINTS "$ENV{PREFIX}\/lib"/' CMakeLists.txt
sed -i'.bkp' -e 's/"-w -O3"/"\$ENV{CFLAGS} -w -O3"/' CMakeLists.txt

cat -n CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -S . -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose

ldd $PREFIX/lib/libMshdist.so
ldd $PREFIX/bin/mshdist