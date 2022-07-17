set -e

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build . --verbose --config Release
cmake --install . --verbose

cp libCommons.* $PREFIX/lib