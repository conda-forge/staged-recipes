export NCURSES_CFLAGS="-I${PREFIX}/include/ncurses"
export NCURSES_LIBS="-L${PREFIX} -lncurses"

./configure \
    --without-x \
    --with-nrnpython=$PYTHON \
    --prefix=$PREFIX \
    --exec-prefix=$PREFIX

make -j ${NUM_CPUS:-1} && make install

# redo Python binding installation
# since package installs in lib/python instead of proper site-packages
rm -rf $PREFIX/lib/python
cd src/nrnpython
python setup.py install
