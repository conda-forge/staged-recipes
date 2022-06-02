#!/bin/bash

set -ex

cd pyston/pyston_lite

make DEFAULT_CC=$CC -C ../LuaJIT -j${CPU_COUNT}

PATH=$PATH:../LuaJIT/src PYSTON_USE_SYS_BINS=1 NOBOLT=1 python setup.py install -v
