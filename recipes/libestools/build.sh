set -exou

sed -i 's/^ifdef GCC/ifeq "0" "1"/' config/compilers/gcc.mak

./configure SHARED=2 DEBUG=1 COMPILER=gcc

make  # cannot build in parallel, the build system does not support it

make install  # only copies files inside the build directory

mkdir -p "${PREFIX}/lib"

cp lib/lib*.so* "${PREFIX}/lib/"
