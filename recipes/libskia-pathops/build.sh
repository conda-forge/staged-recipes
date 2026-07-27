#!/bin/bash
set -ex

SKIA_SRC="${SRC_DIR}/src/cpp/skia-builder/skia"
SKIA_BUILD="${SRC_DIR}/skia-build"
SOVER="${PKG_VERSION%.*}"

case "${target_platform}" in
    linux-aarch64|osx-arm64) SKIA_TARGET_CPU="arm64" ;;
    linux-ppc64le) SKIA_TARGET_CPU="ppc64" ;;
    *) SKIA_TARGET_CPU="x64" ;;
esac

SKIA_GN_ARGS="$(grep -v '^#' "${RECIPE_DIR}/skia_args.gni" | tr '\n' ' ')"
SKIA_GN_ARGS+=" target_cpu=\"${SKIA_TARGET_CPU}\""
SKIA_GN_ARGS+=" cc=\"${CC}\" cxx=\"${CXX}\" ar=\"${AR}\""
# Skia defaults to -fvisibility=hidden; extra_cflags is applied last so
# this override keeps the symbols exported in the shared library below.
EXTRA_CFLAGS='"-fPIC","-fvisibility=default","-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER"'
if [[ "${target_platform}" == osx-* ]]; then
    EXTRA_CFLAGS+=",\"-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}\""
fi
SKIA_GN_ARGS+=" extra_cflags=[${EXTRA_CFLAGS}]"

(cd "${SKIA_SRC}" && \
    gn gen "${SKIA_BUILD}" \
        --script-executable="${BUILD_PREFIX}/bin/python3" \
        --args="${SKIA_GN_ARGS}")
ninja -C "${SKIA_BUILD}" -j${CPU_COUNT} skia

mkdir -p "${PREFIX}/lib" "${PREFIX}/include/skia-pathops"
cp -r "${SKIA_SRC}/include" "${PREFIX}/include/skia-pathops/include"

if [[ "${target_platform}" == osx-* ]]; then
    ${CXX} -dynamiclib ${LDFLAGS} \
        -Wl,-force_load,"${SKIA_BUILD}/libskia.a" \
        -install_name "${PREFIX}/lib/libskia-pathops.${SOVER}.dylib" \
        -o "${PREFIX}/lib/libskia-pathops.${SOVER}.dylib"
    ln -s "libskia-pathops.${SOVER}.dylib" "${PREFIX}/lib/libskia-pathops.dylib"
else
    ${CXX} -shared ${LDFLAGS} \
        -Wl,--whole-archive "${SKIA_BUILD}/libskia.a" -Wl,--no-whole-archive \
        -Wl,-soname,"libskia-pathops.so.${SOVER}" \
        -Wl,-z,defs -lpthread -lm -ldl \
        -o "${PREFIX}/lib/libskia-pathops.so.${SOVER}"
    ln -s "libskia-pathops.so.${SOVER}" "${PREFIX}/lib/libskia-pathops.so"
fi
