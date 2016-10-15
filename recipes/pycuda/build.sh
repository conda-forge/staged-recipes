set -e

./configure.py \
  --cuda-inc-dir=$PREFIX/include \
  --cudadrv-lib-dir=$PREFIX/lib \
  --cudart-lib-dir=$PREFIX/lib \
  --curand-lib-dir=$PREFIX/lib

python setup.py install --single-version-externally-managed --record record.txt
