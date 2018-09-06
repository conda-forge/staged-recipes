set -e

## JUST TO TEST "${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/linux"
./configure.py \
  --cuda-inc-dir="${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/linux" \
  --cudadrv-lib-dir=$PREFIX/lib \
  --cudart-lib-dir=$PREFIX/lib \
  --curand-lib-dir=$PREFIX/lib

$PYTHON setup.py install --single-version-externally-managed --record record.txt
