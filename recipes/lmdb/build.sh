#!/bin/bash

cd libraries/liblmdb/
export DESTDIR=$PREFIX
make
make test
make install
