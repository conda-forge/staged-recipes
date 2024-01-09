#!/bin/bash
set -euo pipefail

./autogen.sh
./configure --prefix=$PREFIX
make prefix=$PREFIX
make install LIBDIR=$PREFIX prefix=$PREFIX
