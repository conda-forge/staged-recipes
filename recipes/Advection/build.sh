set -e

sed -i 's/set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)/#/' CMakeLists.txt
sed -i 's/DESTINATION "$ENV{HOME}/DESTINATION "${CMAKE_INSTALL_PREFIX}/' CMakeLists.txt
sed -i 's/$ENV{HOME}/$ENV{BUILD_PREFIX}/' CMakeLists.txt
set -i 's/set_target_properties( mshdist PROPERTIES INSTALL_RPATH "/usr/local/lib")/#/' CMakeLists.txt

#cat -n CMakeLists.txt

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_SKIP_BUILD_RPATH=TRUE -S . -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose
