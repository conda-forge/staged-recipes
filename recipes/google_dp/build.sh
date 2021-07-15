#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=11.0"
fi
export BAZEL_USE_CPP_ONLY_TOOLCHAIN=1
# set up bazel config file for conda provided clang toolchain
cp -r ${RECIPE_DIR}/custom_clang_toolchain .
pushd custom_clang_toolchain
  sed -e "s:\${CLANG}:${CLANG}:" \
      -e "s:\${INSTALL_NAME_TOOL}:${INSTALL_NAME_TOOL}:" \
      -e "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" \
      cc_wrapper.sh.template > cc_wrapper.sh
  chmod +x cc_wrapper.sh
  sed -i "" "s:\${PREFIX}:${PREFIX}:" cc_toolchain_config.bzl
  sed -i "" "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" cc_toolchain_config.bzl
  sed -i "" "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" cc_toolchain_config.bzl
  sed -i "" "s:\${LD}:${LD}:" cc_toolchain_config.bzl
  sed -i "" "s:\${CFLAGS}:${CFLAGS}:" cc_toolchain_config.bzl
  sed -i "" "s:\${CPPFLAGS}:${CPPFLAGS}:" cc_toolchain_config.bzl
  sed -i "" "s:\${CXXFLAGS}:${CXXFLAGS}:" cc_toolchain_config.bzl
  sed -i "" "s:\${LDFLAGS}:${LDFLAGS}:" cc_toolchain_config.bzl
  sed -i "" "s:\${NM}:${NM}:" cc_toolchain_config.bzl
  sed -i "" "s:\${STRIP}:${STRIP}:" cc_toolchain_config.bzl
  sed -i "" "s:\${AR}:${LIBTOOL}:" cc_toolchain_config.bzl
  sed -i "" "s:\${LIBTOOL}:${LIBTOOL}:" cc_toolchain_config.bzl
popd

pushd differential-privacy/cc
bazel build ... --logging=6 --subcommands --verbose_failures --crosstool_top=//custom_clang_toolchain:toolchain differential-privacy
popd
mkdir -p $PREFIX/bin
cp ../../bazel-bin/differential-privacy/cc $PREFIX/bin