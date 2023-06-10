set -euxo pipefail

cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DTROMPELOEIL_INSTALL_DOCS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build --config Release --target install
