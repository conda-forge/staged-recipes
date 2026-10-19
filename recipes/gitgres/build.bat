rem workaround https://github.com/conda-forge/postgresql-feedstock/issues/308
echo "" > ext/xlocale.h
make -j%CPU_COUNT% CLANG=%BUILD_PREFIX%\bin\clang || exit 1
make -C ext install LLVM_BINPATH=%BUILD_PREFIX%\bin || exit 1

copy backend\gitgres-backend %PREFIX%\bin || exit 1
copy backend\git-remote-gitgres %PREFIX%\bin || exit 1
