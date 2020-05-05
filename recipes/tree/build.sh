ls -al
which gcc || true
make -j${CPU_COUNT}
make install
