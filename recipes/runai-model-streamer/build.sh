#!/bin/bash
set -euxo pipefail

# The upstream build (see cpp/Makefile) is tailored to a devcontainer that ships a
# custom Bazel crosstool (expecting /usr/bin/<arch>-linux-gnu-gcc) and pre-built
# AWS/Azure/GCP SDKs under /opt. The 0001-... patch strips the custom toolchain
# registration and the external repositories from cpp/WORKSPACE because the core
# libstreamer.so -- the only artifact bundled by this wheel -- has no third-party
# C++ dependencies: the s3/gcs/azure backends are separate .so files, shipped in
# their own wheels, that are dlopen'd at runtime. Bazel therefore auto-detects
# the conda-forge compiler through CC/CXX.

export PACKAGE_VERSION="${PKG_VERSION}"

cd cpp

# Plain Bazel (not Bazelisk) ignores .bazelversion; remove it so nothing can
# enforce the upstream-pinned 7.6.1 against the conda-forge bazel.
rm -f .bazelversion

# Build only the core shared library; it has no external dependencies.
bazel build streamer:libstreamer.so --verbose_failures

# setup.py packages runai_model_streamer/libstreamer/lib/libstreamer.so, which
# is a symlink (created by the repo) to cpp/bazel-bin/streamer/libstreamer.so.
cd ../py/runai_model_streamer
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
