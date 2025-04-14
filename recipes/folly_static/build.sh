#!/usr/bin/env bash

set -ex

# Resolves error: 'scm_timestamping' does not name a type
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_SO_TIMESTAMPING=0"

# Resolves error: expected ')' before 'PRId64'
export CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# Resolves error No clock_gettime(3) compatibility wrapper available for this platform.
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_CLOCK_GETTIME=1"

# Resolves error invalid conversion from 'void (*)() noexcept' to 'google::logging_fail_func_t' {aka 'void (*)() __attribute__((noreturn))'}
export CXXFLAGS="$CXXFLAGS -fpermissive"

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="$CXXFLAGS -flax-vector-conversions"
fi

mkdir -p _build
cd _build

if [[ ! -z "${folly_build_ext+x}" && "${folly_build_ext}" == "jemalloc" ]]
then
    CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_JEMALLOC=ON"
else
    CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_JEMALLOC=OFF"
fi

# Values for cross-compilation
if [[ "${target_platform}" == "osx-arm64" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_VSNPRINTF_ERRORS_EXITCODE=1 -DHAVE_VSNPRINTF_ERRORS_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE=0 -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_LINUX_VDSO_EXITCODE=255 -DFOLLY_HAVE_LINUX_VDSO_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE=0 -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE__TRYRUN_OUTPUT=''"
fi
if [[ "${target_platform}" == "linux-aarch64" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE=0 -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_WEAK_SYMBOLS_EXITCODE=0 -DFOLLY_HAVE_WEAK_SYMBOLS_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_LINUX_VDSO_EXITCODE=0 -DFOLLY_HAVE_LINUX_VDSO_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE=0 -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_VSNPRINTF_ERRORS_EXITCODE=0 -DHAVE_VSNPRINTF_ERRORS_EXITCODE__TRYRUN_OUTPUT=''"
fi
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE=0 -DFOLLY_HAVE_UNALIGNED_ACCESS_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_WEAK_SYMBOLS_EXITCODE=0 -DFOLLY_HAVE_WEAK_SYMBOLS_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_LINUX_VDSO_EXITCODE=255 -DFOLLY_HAVE_LINUX_VDSO_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE=0 -DFOLLY_HAVE_WCHAR_SUPPORT_EXITCODE__TRYRUN_OUTPUT=''"
    CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_VSNPRINTF_ERRORS_EXITCODE=0 -DHAVE_VSNPRINTF_ERRORS_EXITCODE__TRYRUN_OUTPUT=''"
fi

cmake ${CMAKE_ARGS} -Wno-dev -GNinja -DBUILD_SHARED_LIBS=OFF ..

cat CMakeCache.txt

cmake --build . --parallel

cmake --install .

cd ..
