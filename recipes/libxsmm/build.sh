#!/bin/bash
make -j${CPU_COUNT} PREFIX=${PREFIX}
make -j${CPU_COUNT} PREFIX=${PREFIX} install
make -j${CPU_COUNT} test
make -j${CPU_COUNT} test-all
