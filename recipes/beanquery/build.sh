#! /bin/bash

set -xeuo pipefail
$PYTHON -m pip install . -vv --no-deps --no-build-isolation

# Some support files get installed as if they were freestanding Python
# packages!
rm -rf $SP_DIR/docs
