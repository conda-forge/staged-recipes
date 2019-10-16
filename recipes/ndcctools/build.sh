
DISABLED=$(echo --without-system-{allpairs,parrot,prune,sand,umbrella,wavefront,weaver})

if [[ $PY3K == 1 ]]; then
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python3-path "${PREFIX}" --with-readline-path no  ${DISABLED}
else
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python-path "${PREFIX}" --with-readline-path no  ${DISABLED}
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

