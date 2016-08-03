./configure                     \
            --prefix=$PREFIX    \
            --with-jpeg=$PREFIX \
            --with-tiff=$PREFIX \
            --with-zlib=$PREFIX

make
make install
