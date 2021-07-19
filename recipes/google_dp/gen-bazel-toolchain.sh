#!/bin/bash

set -euxo pipefail

function apply_cc_template() {
  sed -ie "s:TARGET_CPU:${TARGET_CPU}:" $1
  sed -ie "s:TARGET_LIBC:${TARGET_LIBC}:" $1
  sed -ie "s:TARGET_SYSTEM:${TARGET_SYSTEM}:" $1
  sed -ie "s:TARGET_PLATFORM:${target_platform}:" $1
  sed -ie "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" $1
  sed -ie "s:\${COMPILER_VERSION}:${BAZEL_TOOLCHAIN_COMPILER_VERSION:-}:" $1
  sed -ie "s:\${GCC}:${BAZEL_TOOLCHAIN_GCC}:" $1
  sed -ie "s:\${PREFIX}:${PREFIX}:" $1
  sed -ie "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" $1
  sed -ie "s:\${LD}:${LD}:" $1
  sed -ie "s:\${CFLAGS}:${CFLAGS}:" $1
  sed -ie "s:\${CPPFLAGS}:${CPPFLAGS}:" $1
  sed -ie "s:\${CXXFLAGS}:${CXXFLAGS}:" $1
  sed -ie "s:\${LDFLAGS}:${LDFLAGS}:" $1
  sed -ie "s:\${NM}:${NM}:" $1
  sed -ie "s:\${STRIP}:${STRIP}:" $1
  sed -ie "s:\${AR}:${BAZEL_TOOLCHAIN_AR}:" $1
  sed -ie "s:\${HOST}:${HOST}:" $1
  sed -ie "s:\${LIBCXX}:${BAZEL_TOOLCHAIN_LIBCXX}:" $1
}

export BAZEL_USE_CPP_ONLY_TOOLCHAIN=1

# set up bazel config file for conda provided clang toolchain
cp -r ${RECIPE_DIR}/custom_toolchain .
pushd custom_toolchain
  if [[ "${target_platform}" == osx-* ]]; then
    export BAZEL_TOOLCHAIN_COMPILER_VERSION=$($CC -v 2>&1 | head -n1 | cut -d' ' -f3)
    sed -e "s:\${CLANG}:${CLANG}:" \
        -e "s:\${INSTALL_NAME_TOOL}:${INSTALL_NAME_TOOL}:" \
        -e "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" \
        cc_wrapper.sh.template > cc_wrapper.sh
    chmod +x cc_wrapper.sh
    sed -e "s:\${CLANG}:${CC_FOR_BUILD}:" \
        -e "s:\${INSTALL_NAME_TOOL}:${INSTALL_NAME_TOOL//${HOST}/${BUILD}}:" \
        -e "s:\${CONDA_BUILD_SYSROOT}:${CONDA_BUILD_SYSROOT}:" \
        cc_wrapper.sh.template > cc_wrapper_build.sh
    chmod +x cc_wrapper.sh
    export BAZEL_TOOLCHAIN_GCC="cc_wrapper.sh"
    export BAZEL_TOOLCHAIN_LIBCXX="c++"
    export BAZEL_TOOLCHAIN_AR=${LIBTOOL}
  else
    export BAZEL_TOOLCHAIN_COMPILER_VERSION=$(${CC} -v 2>&1|tail -n1|cut -d' ' -f3)
    export BAZEL_TOOLCHAIN_AR=$(basename ${AR})
    touch cc_wrapper.sh
    export BAZEL_TOOLCHAIN_LIBCXX="stdc++"
    export BAZEL_TOOLCHAIN_GCC="${GCC}"
  fi

  export TARGET_SYSTEM="${HOST}"
  if [[ "${target_platform}" == "osx-64" ]]; then
    export TARGET_LIBC="macosx"
    export TARGET_CPU="darwin_x86_64"
    export TARGET_SYSTEM="x86_64-apple-macosx"
  elif [[ "${target_platform}" == "osx-arm64" ]]; then
    export TARGET_LIBC="macosx"
    export TARGET_CPU="darwin_arm64"
    export TARGET_SYSTEM="arm64-apple-macosx"
  elif [[ "${target_platform}" == "linux-64" ]]; then
    export TARGET_LIBC="unknown"
    export TARGET_CPU="k8"
  elif [[ "${target_platform}" == "linux-aarch64" ]]; then
    export TARGET_LIBC="unknown"
    export TARGET_CPU="aarch64"
  elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
    export TARGET_LIBC="unknown"
    export TARGET_CPU="ppc"
  fi
  export BUILD_SYSTEM=${BUILD}
  if [[ "${build_platform}" == "osx-64" ]]; then
    export BUILD_CPU="darwin"
    export BUILD_SYSTEM="x86_64-apple-macosx"
  elif [[ "${build_platform}" == "osx-arm64" ]]; then
    export BUILD_CPU="darwin"
    export BUILD_SYSTEM="arm64-apple-macosx"
  elif [[ "${build_platform}" == "linux-64" ]]; then
    export BUILD_CPU="k8"
  elif [[ "${build_platform}" == "linux-aarch64" ]]; then
    export BUILD_CPU="aarch64"
  elif [[ "${build_platform}" == "linux-ppc64le" ]]; then
    export BUILD_CPU="ppc"
  fi
  # The current Bazel release cannot distinguish between osx-arm64 and osx-64.
  # This will change with later releases and then we should get rid of this section again.
  #if [[ "${target_platform}" == osx-* ]]; then
  #  if [[ "${build_platform}" == "${target_platform}" ]]; then
  #    export TARGET_CPU="darwin"
  #    export BUILD_CPU="darwin"
  #  fi
  #fi
  
  sed -ie "s:TARGET_CPU:${TARGET_CPU}:" BUILD
  sed -ie "s:BUILD_CPU:${BUILD_CPU}:" BUILD

  cp cc_toolchain_config.bzl cc_toolchain_build_config.bzl
  apply_cc_template cc_toolchain_config.bzl
  (
    if [[ "${build_platform}" != "${target_platform}" ]]; then
      if [[ "${target_platform}" == osx-* ]]; then
        BAZEL_TOOLCHAIN_GCC=cc_wrapper_build.sh
      else
        BAZEL_TOOLCHAIN_GCC=${BAZEL_TOOLCHAIN_GCC//${HOST}/${BUILD}}
      fi
      TARGET_CPU=${BUILD_CPU}
      TARGET_SYSTEM=${BUILD_SYSTEM}
      target_platform=${build_platform}
      PREFIX=${BUILD_PREFIX}
      LD=${LD//${HOST}/${BUILD}}
      CFLAGS=${CFLAGS//${PREFIX}/${BUILD_PREFIX}}
      CPPFLAGS=${CPPFLAGS//${PREFIX}/${BUILD_PREFIX}}
      CXXFLAGS=${CXXFLAGS//${PREFIX}/${BUILD_PREFIX}}
      LDFLAGS=${LDFLAGS//${PREFIX}/${BUILD_PREFIX}}
      NM=${NM//${HOST}/${BUILD}}
      STRIP=${STRIP//${HOST}/${BUILD}}
      BAZEL_TOOLCHAIN_AR=${BAZEL_TOOLCHAIN_AR//${HOST}/${BUILD}}
      HOST=${BUILD}
    fi
    apply_cc_template cc_toolchain_build_config.bzl
  )
popd
