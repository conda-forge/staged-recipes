#!/bin/bash

set -eux

${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} AllTests.c CuTestTest.c -I "${PREFIX}/include" -lcutest -o CuTest_tests
./CuTest_tests
