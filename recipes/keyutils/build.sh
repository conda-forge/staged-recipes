#!/bin/bash
declare -a make_args
make_args+=("PREFIX=$PREFIX/")
make_args+=("LIBDIR=lib")
make_args+=("INCLUDEDIR=include")
make_args+=("ETCDIR=etc")
make_args+=("SHAREDIR=share/keyutils")
make_args+=("MANDIR=share/man")
make "${make_args[@]}"

make "${make_args[@]}" DESTDIR=$PREFIX/ install

# The tests don't really work properly inside a docker container
# SKIPROOTREQ=yes make "${make_args[@]}" test
