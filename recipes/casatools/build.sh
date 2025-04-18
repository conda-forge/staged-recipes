#! /bin/bash

set -xeuo pipefail
cd casatools
echo "$PKG_VERSION $PKG_VERSION - -" >version.txt
exec python -m pip install . -vv --no-deps --no-build-isolation
