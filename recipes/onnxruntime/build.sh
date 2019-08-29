#!/bin/sh

${PYTHON} tools/ci_build/build.py --build_dir build/Linux --config Release \
  --enable_pybind --build_wheel \
  --use_openmp --use_mkldnn

${PYTHON} -m pip install build/Linux/Release/dist/*.whl
