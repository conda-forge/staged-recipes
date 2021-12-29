# We follow the hdf5 plugin path from the conda-forge recipe
# https://github.com/conda-forge/hdf5-feedstock/blob/master/recipe/build.sh#L86
./configure \
    --prefix=${PREFIX} \
    --with-hdf5-plugin-path="${PREFIX}/lib/hdf5/plugin" \
    --enable-static=no

make -j${CPU_COUNT}
make check
make install
