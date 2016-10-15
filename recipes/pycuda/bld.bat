configure.py \
  --cuda-inc-dir=%LIBRARY_INC%/include \
  --cudadrv-lib-dir=%LIBRARY_LIB%/lib \
  --cudart-lib-dir=%LIBRARY_LIB%/lib \
  --curand-lib-dir=%LIBRARY_LIB%/lib

python setup.py install --single-version-externally-managed --record record.txt
