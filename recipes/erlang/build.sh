#!/usr/bin/env bash

export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export ERL_TOP="$(pwd)"
./configure --with-ssl="${PREFIX}" --prefix="${PREFIX}" --without-javac \
  --with-libatomic_ops="${PREFIX}" --enable-m${ARCH}-build
make
make release_tests
cd "${ERL_TOP}/release/tests/test_server"
${ERL_TOP}/bin/erl -s ts install -s ts smoke_test batch -s init stop
cd ${ERL_TOP}
make install
