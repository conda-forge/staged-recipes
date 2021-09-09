set -exou

./configure --prefix $PREFIX \
            --libdir ${PREFIX}/lib \
            --bindir ${PREFIX}/bin \
            --disable-qt5 \
            --disable-gtk3 \
            --disable-gdbm \
            --disable-python \
            --disable-mono

make -j$(nproc)
make install
