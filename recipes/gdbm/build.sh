./configure --prefix="${PREFIX}" \
            --enable-static=no
make
make check
make install
