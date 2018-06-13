./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --without-matlab
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} install

# manually remove unwanted executables
rm -vf \
    ${PREFIX}/bin/_getMetaLoopHelper \
    ${PREFIX}/bin/concatMeta
