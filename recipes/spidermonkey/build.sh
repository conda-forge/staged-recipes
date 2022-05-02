export LIBXUL_DIST=$out
export M4=m4
export AWK=awk
export LLVM_OBJDUMP=objdump
export CPPFLAGS="-D__STDC_FORMAT_MACROS $CPPFLAGS"

# We can't build in js/src/, so create a build dir
mkdir obj
cd obj/
python ../configure.py --prefix=$PREFIX --enable-project=js --disable-ctypes --disable-jit --disable-jemalloc --enable-optimize --enable-hardening --with-intl-api --build-backends=RecursiveMake --with-system-icu --disable-debug --enable-gczeal
make
make install
