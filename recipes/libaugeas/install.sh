./configure --prefix "${PREFIX}"
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

if [[ "$PKG_NAME" == *static ]]
then
    # relying on conda to dedup package
    echo "Keeping all files, conda will dedupe"
else
    rm -rf ${PREFIX}/lib/*.a
fi
