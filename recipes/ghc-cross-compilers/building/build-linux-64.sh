#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

# Update cabal package database
run_and_log "cabal-update" cabal v2-update

_hadrian_build=("${SRC_DIR}"/hadrian/build "-j${CPU_COUNT}")

# Create aarch64 environment and get library paths
echo "Creating aarch64 environment for cross-compilation libraries..."
conda create -y \
    -n aarch64_env \
    --platform linux-aarch64 \
    -c conda-forge \
    gmp \
    libffi \
    libiconv \
    ncurses

sleep 10

# Get the environment path and set up library paths
AARCH64_ENV_PATH=$(conda info --envs | grep aarch64_env | awk '{print $2}')
export AARCH64_LIB_DIR="${AARCH64_ENV_PATH}/lib"
export AARCH64_INCLUDE_DIR="${AARCH64_ENV_PATH}/include"

AARCH64_CFLAGS=$(echo "$CFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
AARCH64_CFLAGS=$(echo "$AARCH64_CFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
AARCH64_CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
AARCH64_CXXFLAGS=$(echo "$AARCH64_CXXFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
AARCH64_CPPFLAGS=$(echo "$CPPFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
AARCH64_CPPFLAGS=$(echo "$AARCH64_CPPFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')

echo "aarch64 libraries located at: ${AARCH64_LIB_DIR}"
echo "aarch64 headers located at: ${AARCH64_INCLUDE_DIR}"

# Configure and build GHC
SYSTEM_CONFIG=(
  --build="x86_64-conda-linux-gnu"
  --host="x86_64-conda-linux-gnu"
  --target="aarch64-unknown-linux"
  --prefix="${PREFIX}"
)

CONFIGURE_ARGS=(
  --enable-ignore-build-platform-mismatch=yes
  --disable-numa
  --with-system-libffi=yes
  --with-curses-includes="${AARCH64_INCLUDE_DIR}"
  --with-curses-libraries="${AARCH64_LIB_DIR}"
  --with-ffi-includes="${AARCH64_INCLUDE_DIR}"
  --with-ffi-libraries="${AARCH64_LIB_DIR}"
  --with-gmp-includes="${AARCH64_INCLUDE_DIR}"
  --with-gmp-libraries="${AARCH64_LIB_DIR}"
  --with-iconv-includes="${AARCH64_INCLUDE_DIR}"
  --with-iconv-libraries="${AARCH64_LIB_DIR}"
)

# Set up aarch64 cross-compilation toolchain
MergeObjsCmd=aarch64-conda-linux-gnu-ld.gold \
AR=aarch64-conda-linux-gnu-ar \
AS=aarch64-conda-linux-gnu-as \
CC=aarch64-conda-linux-gnu-clang \
CXX=aarch64-conda-linux-gnu-clang++ \
LD=aarch64-conda-linux-gnu-ld \
NM=aarch64-conda-linux-gnu-nm \
OBJDUMP=aarch64-conda-linux-gnu-objdump \
RANLIB=aarch64-conda-linux-gnu-ranlib \
CFLAGS="${AARCH64_CFLAGS}" \
CXXFLAGS="${AARCH64_CXXFLAGS}" \
run_and_log "ghc-configure" bash configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"

# Patch host/target configurations
perl -pi -e 's#"--target=[\w-]+"#"--target=x86_64-unknown-linux","--sysroot=$ENV{BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot"#'  "${SRC_DIR}"/hadrian/cfg/default.host.target
perl -pi -e 's/aarch64/x86_64/;s/ArchAArch64/ArchX86_64/' "${SRC_DIR}"/hadrian/cfg/default.host.target

perl -pi -e 's#"--target=[\w-]+"#"--target=aarch64-unknown-linux","--sysroot=$ENV{BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"#'  "${SRC_DIR}"/hadrian/cfg/default.target
perl -pi -e 's#"--target=[\w-]+"#"--target=aarch64-unknown-linux","--sysroot=$ENV{BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"#'  "${SRC_DIR}"/hadrian/cfg/default.target
# perl -pi -e 's#(settings-llvm-as-command = )([\w-]+)#\1"\2 --target=x86_64-unknown-linux"#'  "${SRC_DIR}"/hadrian/cfg/system.config

perl -pi -e 's#(settings-llvm-as-command = )([\w-]+)#\1aarch64-conda-linux-gnu-as#'  "${SRC_DIR}"/hadrian/cfg/system.config

# Create UserSettings.hs for Stage1 cross-compiler build
cat ${RECIPE_DIR}/cross-UserSettings.hs > hadrian/UserSettings.hs

mkdir -p ${SRC_DIR}/_cross-compiler
run_and_log "binary-dist" "${_hadrian_build[@]}" binary-dist --prefix="${SRC_DIR}/_cross-compiler" --docs=none --progress-info=none --flavour=perf

export MergeObjsCmd=aarch64-conda-linux-gnu-ld.gold
export AR=aarch64-conda-linux-gnu-ar
export AS=aarch64-conda-linux-gnu-as
export CC=aarch64-conda-linux-gnu-clang
export CXX=aarch64-conda-linux-gnu-clang++
export LD=aarch64-conda-linux-gnu-ld
export LD_GOLD=aarch64-conda-linux-gnu-ld.gold
export NM=aarch64-conda-linux-gnu-nm
export RANLIB=aarch64-conda-linux-gnu-ranlib

export build_alias=x86_64-conda-linux-gnu
export host_alias=x86_64-conda-linux-gnu
export target_alias=aarch64-unknown-linux

# Clear x86_64 flags that break aarch64 cross-compiler and set correct sysroot
export CFLAGS="${AARCH64_CFLAGS} --sysroot=${BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"
export CXXFLAGS="${AARCH64_CXXFLAGS} --sysroot=${BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"
export CPPFLAGS="${AARCH64_CPPFLAGS}"
export LDFLAGS="--sysroot=${BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"

run_and_log "cross-install" "${_hadrian_build[@]}" install --prefix="${SRC_DIR}/_cross-compiler" --flavour=perf --docs=none

# Create aarch64-prefixed binaries for the cross-compiler
pushd "${SRC_DIR}"/_cross-compiler
  # Rename the cross-compiler links to binaries to aarch64-conda-linux-gnu-* format
  for prog in $(find bin -name "aarch64-unknown-linux-*"); do
    if [[ "${prog}" != *"-${PKG_VERSION}" ]]; then
      mv "${prog}" $(echo "${prog}" | sed 's/aarch64-unknown-linux-/aarch64-conda-linux-gnu-/')
    fi
  done
  
  # Just to be safe with the native naming
  rm -rf share/ghc-"${PKG_VERSION}"
popd

# Patch the settings file AFTER moving to PREFIX so paths are correct
# Move to PREFIX first
(cd "${SRC_DIR}/_cross-compiler" && tar cf - ./* | (cd "${PREFIX}" && tar xf -) )

settings_file=$(find "${PREFIX}" -name settings -type f | grep aarch64 | head -1)
echo "Fixing settings file: $settings_file"

# We enforce prioritizing the sysroot for self-consistently finding the libraries
if [[ -f "$settings_file" ]]; then
  # The settings already have the right compiler and basic sysroot, just add include path override
  perl -i -pe 's#("C compiler flags", ")([^"]*)"#\1\2 -isysroot \$topdir/../../../aarch64-conda-linux-gnu/sysroot"#g' "${settings_file}"
  perl -i -pe 's#("C\+\+ compiler flags", ")([^"]*)"#\1\2 -isysroot \$topdir/../../../aarch64-conda-linux-gnu/sysroot"#g' "${settings_file}"
  perl -i -pe 's#("CPP compiler flags", ")([^"]*)"#\1\2 -isysroot \$topdir/../../../aarch64-conda-linux-gnu/sysroot"#g' "${settings_file}"
  
  perl -i -pe 's#("C compiler link flags", ")([^"]*)"#\1\2 -L\$topdir/../../../lib -Wl,-rpath,\$topdir/../../../lib"#g' "${settings_file}"
  
  perl -i -pe 's#("LLVM llvm-as command", ")([^"]*)"#\1aarch64-conda-linux-gnu-clang"#g' "${settings_file}"
  
  echo "Settings file patched successfully"
else
  echo "Warning: Settings file not found at $settings_file"
fi

# Fix hardcoded paths in wrapper scripts
echo "Fixing wrapper script paths..."
find "${PREFIX}/bin" -name "*ghc*" -type f | grep "aarch64" | while read -r wrapper; do
  if grep -q -E "(exedir=|includedir=|libdir=|docdir=|mandir=|datadir=)" "$wrapper"; then
    echo "Fixing paths in: $wrapper"
    # Replace all hardcoded absolute paths with relative paths (POSIX sh compatible)
    perl -i -pe 's#exedir="[^"]*"#exedir="\$( cd "\$( dirname "\$0" )/../lib/aarch64-unknown-linux-ghc-'"${PKG_VERSION}"'/bin" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#executablename="[^"]*"#executablename="\$exedir/\$exeprog"#g' "$wrapper"
    perl -i -pe 's#bindir="[^"]*"#bindir="\$( cd "\$( dirname "\$0" )" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#libdir="[^"]*"#libdir="\$( cd "\$( dirname "\$0" )/../lib/aarch64-unknown-linux-ghc-'"${PKG_VERSION}"'/lib" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#includedir="[^"]*"#includedir="\$( cd "\$( dirname "\$0" )/../include" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#docdir="[^"]*"#docdir="\$( cd "\$( dirname "\$0" )/../share/doc/aarch64-unknown-linux-ghc-'"${PKG_VERSION}"'" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#mandir="[^"]*"#mandir="\$( cd "\$( dirname "\$0" )/../share/man" \&\& pwd )"#g' "$wrapper"
    perl -i -pe 's#datadir="[^"]*"#datadir="\$( cd "\$( dirname "\$0" )/../share" \&\& pwd )"#g' "$wrapper"
    echo "Fixed: $wrapper"
  fi
done

# We need to map the PREFIX environment sysroot
mkdir -p "${PREFIX}"/aarch64-conda-linux-gnu && ln -s "${BUILD_PREFIX}"/aarch64-conda-linux-gnu/sysroot "${PREFIX}"/aarch64-conda-linux-gnu/sysroot

# Enforce sysroot usage for interdependent system lib
# Solves librt.so needing libpthreads.so but finding the /lib64
# instead of the self-consistent sysrrot
sysroot_lib64="${PREFIX}/aarch64-conda-linux-gnu/sysroot/lib64"
sysroot_usr_lib64="${PREFIX}/aarch64-conda-linux-gnu/sysroot/usr/lib64"
conda_lib="${PREFIX}/lib"

echo "Patching binaries and libraries"
{
    find "${PREFIX}"/bin -type f -executable | grep "aarch64" | grep "ghc"
    find "${PREFIX}"/lib -name "*.so*" | grep "aarch64" | grep "ghc"
} | while read -r binary; do
  if file "$binary" | grep -q "ELF"; then
    current_rpath=$(patchelf --print-rpath "$binary" 2>/dev/null || echo "")
    _sysroot_lib64="$(calculate_origin_rpath "$binary" "$sysroot_lib64")"
    _sysroot_usr_lib64="$(calculate_origin_rpath "$binary" "$sysroot_usr_lib64")"
    _conda_lib="$(calculate_origin_rpath "$binary" "$conda_lib")"
    new_rpath="${_sysroot_lib64}:${_sysroot_usr_lib64}:${_conda_lib}"
    if [[ -n "$current_rpath" ]]; then
      new_rpath="${new_rpath}:${current_rpath}"
    fi
    patchelf --set-rpath "$new_rpath" "$binary" 2>/dev/null && echo -n "."
  fi
done
echo " done"

rm -rf "${PREFIX}"/aarch64-conda-linux-gnu
