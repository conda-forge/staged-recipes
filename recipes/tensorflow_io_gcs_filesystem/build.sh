#!/bin/bash

# copy pkg


# Install tensorflow and configure bazel
./configure.sh


# # Alias python3 to python, needed by bazel
# ln -s /usr/bin/python3 /usr/bin/python

# Add any optimization on bazel command, e.g., --compilation_mode=opt,
#   --copt=-msse4.2, --remote_cache=, etc.
# export BAZEL_OPTIMIZATION=

# Get rid of unwanted defaults
sed -i -e "/PROTOBUF_INCLUDE_PATH/c\ " .bazelrc
sed -i -e "/PREFIX/c\ " .bazelrc

# Build shared libraries
bazel build -s --verbose_failures --define=PROTOBUF_INCLUDE_PATH=${PREFIX}/include --define=PREFIX=${PREFIX} --config=noaws $BAZEL_OPTIMIZATION //tensorflow_io/... //tensorflow_io_gcs_filesystem/...

# # Once build is complete, shared libraries will be available in
# # `bazel-bin/tensorflow_io/core`, `bazel-bin/tensorflow_io/python/ops` and
# # it is possible to run tests with `pytest`, e.g.:
# sudo python3 -m pip install pytest
# TFIO_DATAPATH=bazel-bin python3 -m pytest -s -v tests/test_serialization.py
