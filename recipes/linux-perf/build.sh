set -eu

unset ARCH

ARGS=(
    "-fMakefile.perf"
    "VF=x"
    "-j$CPU_COUNT"
    "prefix=$PREFIX"
    "LIBZSTD_DIR=$PREFIX"
    "LIBUNWIND_DIR=$PREFIX"
    "EXTRA_CFLAGS=-I$PREFIX/include"
    "PYTHON_CONFIG=python3-config"
    "NO_LIBPERL=x"
    "WERROR=0"
    "HOSTCC=$CC_FOR_BUILD"
    "HOSTLD=$LD"
    "HOSTAR=$AR"
)

make clean
cd tools/perf
make "${ARGS[@]}"
make "${ARGS[@]}" install
