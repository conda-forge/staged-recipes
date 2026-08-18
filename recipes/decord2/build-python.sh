#!/bin/bash
set -euxo pipefail

# The shared library is provided by the libdecord2 package (already installed
# into $PREFIX/lib as a host dependency). Point decord2's build machinery at it
# so setup.py can locate libdecord.so instead of searching system paths.
export DECORD_LIBRARY_PATH="${PREFIX}/lib"

pushd python
  ${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd

# setup.py bundles a copy of libdecord.so inside the Python package. Remove it:
# the library ships in the libdecord2 package and is discovered at runtime from
# $PREFIX/lib, avoiding a duplicated, unmanaged copy.
rm -f "${SP_DIR}/decord/libdecord.so"
