set -e

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} -DTEST_LIBMMG3D=OFF -DTEST_LIBMMG2D=OFF -DTEST_LIBMMGS=OFF -DTEST_LIBMMG=OFF -DUSE_VTK=OFF -DUSE_ELAS=ON -S . -B build
cmake --build ./build --verbose --config Release
cmake --install ./build --verbose
