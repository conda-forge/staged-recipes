#!/bin/bash
set -euo pipefail

./autogen.sh
# custom LD for windows needed
LD=$LD ./configure --prefix=$(realpath $PREFIX)
make prefix=$(realpath $PREFIX)
make install prefix=$(realpath $PREFIX)
