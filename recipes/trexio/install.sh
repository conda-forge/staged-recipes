#!/bin/bash

set -e
set -x

make install V=1

make -j "${CPU_COUNT}" check

