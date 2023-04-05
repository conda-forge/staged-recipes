set -euxo pipefail

cmake -S . -B build -G "Ninja" -DGSL_TEST=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build --config Release --target install
