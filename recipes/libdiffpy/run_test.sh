#!/bin/bash

export CPATH="${PREFIX}/include:${CPATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"

MYNCPU=$(( (CPU_COUNT > 8) ? 8 : CPU_COUNT ))

# Build the unit tests program using the installed library.
scons -j $MYNCPU alltests prefix=$PREFIX test_installed=true

# Execute the unit tests.
MYALLTESTSFAST=$(ls -t ${PWD}/build/fast*/tests/alltests | head -1)
${MYALLTESTSFAST}