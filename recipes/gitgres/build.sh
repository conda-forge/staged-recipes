set -x -e

# workaround https://github.com/conda-forge/postgresql-feedstock/issues/308
> ext/xlocale.h
make "-j${CPU_COUNT}" CLANG="${BUILD_PREFIX}/bin/clang"
make -C ext install LLVM_BINPATH="${BUILD_PREFIX}/bin"

cp -p backend/{gitgres-backend,git-remote-gitgres} "${PREFIX}/bin/"
