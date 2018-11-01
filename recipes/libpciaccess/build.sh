set -ex
export ACLOCAL="aclocal -I ${PREFIX}/share/aclocal"
autoreconf --install
./autogen.sh --prefix=$PREFIX
make install
