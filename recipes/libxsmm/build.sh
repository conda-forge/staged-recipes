#!/bin/bash
make -j${CPU_COUNT} PREFIX=${PREFIX}
make -j${CPU_COUNT} install
make -j${CPU_COUNT} test
make -j${CPU_COUNT} test-all
