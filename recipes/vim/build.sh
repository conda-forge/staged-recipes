# For some reason vim doesn't use standard CFLAGS for OSDEF
# https://github.com/vim/vim/blob/5fd0f5052f9a312bb4cfe7b4176b1211d45127ee/src/Makefile#L1478
export EXTRA_IPATHS="-I$PREFIX/include"

./configure --prefix=$PREFIX    \
            --without-x         \
            --without-gnome     \
            --without-tclsh     \
            --without-local-dir \
            --enable-gui=no     \
            --enable-cscope     \
            --enable-pythoninterp=yes  || { cat src/auto/config.log; exit 1; }

make
make install
