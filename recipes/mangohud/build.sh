set -ex
configure

ninja -j${CPU_COUNT}

ninja install
