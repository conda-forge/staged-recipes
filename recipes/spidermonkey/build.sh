export LIBXUL_DIST=$out
export PYTHON=python
export M4=m4
export AWK=awk
export AC_MACRODIR=$PWD/build/autoconf/
pushd js/src
sh ../../build/autoconf/autoconf.sh --localdir=$PWD configure.in > configure
chmod +x configure
popd
# We can't build in js/src/, so create a build dir
mkdir obj
cd obj/
../js/src/configure --disable-ctypes --disable-jit --disable-jemalloc --enable-optimize --enable-hardening --with-intl-api --build-backends=RecursiveMake --with-system-icu --disable-debug --enable-gczeal
make
