set -e

sed -i'.bkp' -e 's/set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)/#/' CMakeLists.txt
sed -i'.bkp' -e 's/DESTINATION "$ENV{HOME}/DESTINATION "${CMAKE_INSTALL_PREFIX}/' CMakeLists.txt
sed -i'.bkp' -e 's/$ENV{HOME}/$ENV{BUILD_PREFIX}/' CMakeLists.txt

cat -n CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_SKIP_BUILD_RPATH=TRUE -S . -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose
