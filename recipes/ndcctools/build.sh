#! /usr/bin/env bash

DISABLED=$(echo --without-system-{allpairs,parrot,prune,sand,umbrella,wavefront,weaver})

if [[ $PY3K == 1 ]]; then
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python3-path "${PREFIX}" --with-readline-path no  ${DISABLED}
else
    ./configure --prefix "${PREFIX}" --with-base-dir "${PREFIX}" --with-python-path "${PREFIX}" --with-readline-path no  ${DISABLED}
fi

make
make install
make test
