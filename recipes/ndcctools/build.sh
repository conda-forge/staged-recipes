
DISABLED_SYS=$(echo --without-system-{allpairs,parrot,prune,sand,umbrella,wavefront,weaver})
DISABLED_LIB=$(echo --with-{readline,fuse}-path\ no)

if [[ $PY3K == 1 ]]; then
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python3-path "${PREFIX}" ${DISABLED_LIB} ${DISABLED_SYS}
else
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python-path "${PREFIX}" ${DISABLED_LIB} ${DISABLED_SYS}
fi

make -j${CPU_COUNT}
make install

if ! make test
then
    cat cctools.test.fail
    exit 1
else
    exit 0
fi

