#!/usr/bin/env bash
set -euxo pipefail

# Extract only what the build uses from the two large source archives (see
# recipe.yaml). These paths come from make/gen-device.mk and make/release.mk.
mkdir -p llvm-project lib/cmsis-svd
llvm_top="llvm-project-${LLVM_FORK_COMMIT}"
tar -xzf archives/llvm-project.tar.gz -C llvm-project --strip-components=1 \
  "${llvm_top}/compiler-rt/lib/builtins" \
  "${llvm_top}/compiler-rt/LICENSE.TXT" \
  "${llvm_top}/clang/lib/Headers" \
  "${llvm_top}/clang/LICENSE.TXT" \
  "${llvm_top}/lld/LICENSE.TXT"
svd_top="cmsis-svd-data-${CMSIS_SVD_COMMIT}"
svd_members=("${svd_top}/LICENSE-APACHE")
for vendor in Atmel Espressif Espressif-Community Kendryte-Community NXP RaspberryPi Renesas SiFive-Community; do
  svd_members+=("${svd_top}/data/${vendor}")
done
tar -xzf archives/cmsis-svd-data.tar.gz -C lib/cmsis-svd --strip-components=1 "${svd_members[@]}"
rm -rf archives

# Link against conda-forge's LLVM, clang and lld instead of a source-built
# LLVM tree. This mirrors CGO_*FLAGS from make/llvm.mk, but uses the shared
# libLLVM, libclang and libclang-cpp. lld is only available as static
# component libraries. The shared libLLVM has no system-libs, so the
# zlib/zstd that liblldELF needs are added explicitly.
LLD_LIBS="lldCOFF lldCommon lldELF lldMachO lldMinGW lldWasm"

lld_link_libs=""
for lib in ${LLD_LIBS}; do
  lld_link_libs="${lld_link_libs} -l${lib}"
done

if [[ "${target_platform}" == osx-* ]]; then
  CXX_STDLIB="-lc++"
  START_GROUP=""
  END_GROUP=""
else
  CXX_STDLIB="-lstdc++"
  START_GROUP="-Wl,--start-group"
  END_GROUP="-Wl,--end-group"
fi

# These are what llvm-config --cppflags/--ldflags/--libs print for
# conda-forge's shared libLLVM. llvm-config itself is not called because
# $PREFIX/bin/llvm-config cannot run when cross-compiling.
export CGO_CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"
export CGO_CFLAGS="${CFLAGS}"
export CGO_CXXFLAGS="${CXXFLAGS} -std=c++17"
export CGO_LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lclang -lclang-cpp ${START_GROUP} ${lld_link_libs} ${END_GROUP} -lLLVM-${LLVM_MAJOR} -lz -lzstd ${CXX_STDLIB}"

# The work dir may sit inside a git checkout (e.g. staged-recipes CI).
export GOFLAGS="-buildvcs=false"

GO_TAGS="byollvm llvm${LLVM_MAJOR} osusergo"

mkdir -p build
go build -buildmode exe -trimpath -ldflags "-s -w" -tags "${GO_TAGS}" -o build/tinygo .

go-licenses save . --save_path="${SRC_DIR}/license-files" \
  --ignore github.com/tinygo-org/tinygo

# Generate device files and assemble the release tree using the upstream
# Makefile. The tinygo binary is already built above, so skip remaking it.
# The device generators run during the build, so build them for the build
# machine rather than the target.
make -o tinygo build/release \
  GO="env -u GOOS -u GOARCH CGO_ENABLED=0 go" \
  USE_SYSTEM_BINARYEN=1 \
  LLVM_PROJECTDIR=llvm-project \
  BREW_PREFIX=

mkdir -p "${PREFIX}/lib" "${PREFIX}/bin"
cp -R build/release/tinygo "${PREFIX}/lib/tinygo"

# tinygo derives TINYGOROOT from the directory of its executable, so expose
# it through a small wrapper rather than a symlink (macOS does not resolve
# symlinks in os.Executable).
cat > "${PREFIX}/bin/tinygo" <<'EOF'
#!/bin/sh
exec "$(dirname "$0")/../lib/tinygo/bin/tinygo" "$@"
EOF
chmod +x "${PREFIX}/bin/tinygo"
