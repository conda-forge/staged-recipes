#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${SRC_DIR}/../build_energyplus"
mkdir -p "${BUILD_DIR}"
"${PYTHON}" "${RECIPE_DIR}/prepare.py" patch

# Fix an uninitialized member in the bundled Windows-CalcEngine.
sed -i.bak 's/bool m_DefaultGas;/bool m_DefaultGas = false;/' \
    "${SRC_DIR}/third_party/Windows-CalcEngine/src/Gases/src/Gas.hpp"

# A fixed underlying type permits Boost.MPL's out-of-range enum arithmetic.
_boost_nc="${SRC_DIR}/third_party/kiva/vendor/boost-1.88.0/boost/numeric/conversion"
sed -i.bak 's/enum int_float_mixture_enum$/enum int_float_mixture_enum : int/' \
    "${_boost_nc}/int_float_mixture_enum.hpp"
sed -i.bak 's/enum udt_builtin_mixture_enum$/enum udt_builtin_mixture_enum : int/' \
    "${_boost_nc}/udt_builtin_mixture_enum.hpp"
sed -i.bak 's/enum sign_mixture_enum$/enum sign_mixture_enum : int/' \
    "${_boost_nc}/sign_mixture_enum.hpp"

# Bundled sources need missing includes and compiler-specific warning workarounds.
EXTRA_CXX_FLAGS="-include cstdint -include algorithm"
if "${CXX:-c++}" --version 2>&1 | grep -q clang; then
    EXTRA_CXX_FLAGS="${EXTRA_CXX_FLAGS} -Wno-deprecated-declarations -Wno-unknown-warning-option"
else
    EXTRA_CXX_FLAGS="${EXTRA_CXX_FLAGS} -Wno-dangling-reference -Wno-restrict -Wno-alloc-size-larger-than"
fi

# Reserve enough ELF RPATH space for rattler-build's relocation.
_rpath="${PREFIX}/lib"
while [ ${#_rpath} -lt 256 ]; do _rpath="${_rpath}/././"; done

EXTRA_CMAKE_ARGS="-DCMAKE_CXX_SCAN_FOR_MODULES=OFF"
if [ -n "${CLANG:-}" ]; then
    EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_C_COMPILER=${CLANG}"
fi

# EnergyPlus requires libc++'s floating-point std::format support.
if [[ "$(uname)" == "Darwin" ]]; then
    _old_mdt="${MACOSX_DEPLOYMENT_TARGET:-}"
    export MACOSX_DEPLOYMENT_TARGET=13.3
    if [ -n "${_old_mdt}" ]; then
        CFLAGS="${CFLAGS//-mmacosx-version-min=${_old_mdt}/-mmacosx-version-min=13.3}"
        CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=${_old_mdt}/-mmacosx-version-min=13.3}"
        CPPFLAGS="${CPPFLAGS//-mmacosx-version-min=${_old_mdt}/-mmacosx-version-min=13.3}"
        LDFLAGS="${LDFLAGS//-mmacosx-version-min=${_old_mdt}/-mmacosx-version-min=13.3}"
        export CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
    fi
    EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=13.3"
fi

# shellcheck disable=SC2086
cmake ${CMAKE_ARGS} ${EXTRA_CMAKE_ARGS} \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${EXTRA_CXX_FLAGS}" \
  -DBUILD_FORTRAN=ON \
  -DOPENGL_REQUIRED=OFF \
  -DDOCUMENTATION_BUILD=DoNotBuild \
  -DBUILD_TESTING=OFF \
  -DBUILD_PACKAGE=ON \
  -DLINK_WITH_PYTHON=ON \
  -DPYTHON_CLI=OFF \
  -DPython_ROOT_DIR="${PREFIX}" \
  -DPython_FIND_STRATEGY=LOCATION \
  -DCMAKE_INSTALL_RPATH="${_rpath}" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -B "${BUILD_DIR}" \
  -S "${SRC_DIR}"

cmake --build "${BUILD_DIR}" --target install -j"${CPU_COUNT:-2}"
"${PYTHON}" "${RECIPE_DIR}/prepare.py" clean "${BUILD_DIR}"

mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/energyplus" << 'WRAPPER'
#!/usr/bin/env bash
_ep_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${_ep_dir}/energyplus" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/energyplus"

mkdir -p "${SP_DIR}"
echo "${PREFIX}" > "${SP_DIR}/energyplus.pth"
