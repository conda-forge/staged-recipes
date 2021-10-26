set -euxo pipefail
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_PYTHON_WRAPPER=ON
make
make install