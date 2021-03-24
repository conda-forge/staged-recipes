set -e

## JUST TO TEST "${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/linux"
./configure.py

$PYTHON setup.py install --single-version-externally-managed --record record.txt
