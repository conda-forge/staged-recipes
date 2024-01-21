#!/bin/bash

set -eux

${CC} AllTests.c CuTestTest.c -I "${PREFIX}/include" -lcutest -o CuTest_tests
./CuTest_tests
