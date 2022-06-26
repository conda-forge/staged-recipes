set -e
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DTEST_LIBMMG3D=OFF -DTEST_LIBMMG2D=OFF -DTEST_LIBMMGS=OFF -DTEST_LIBMMG=OFF -DUSE_VTK=OFF -DUSE_ELAS=ON
cmake --build . --verbose --config Release
cmake --install . --verbose
