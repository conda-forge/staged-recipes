#!/bin/bash

set -ex

# compile
make -j$CPU_COUNT

# test
make quicktest
