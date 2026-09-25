#!/usr/bin/env bash
set -euxo pipefail

mkdir -p dist

if [[ "${target_platform}" == "win-64" ]]; then
    include_dir="$(cygpath -m "${LIBRARY_INC}")"
    library_lib="$(cygpath -u "${LIBRARY_LIB}")"

    # Generate sqlite-vec.h
    make sqlite-vec.h

    # Build the extension with MSVC (note we don't use `/Ivendor` but `/I${include_dir}`)
    # Refer - https://github.com/asg017/sqlite-vec/blob/e9f598abfa0c06b328d8fe5da9c3760cce74be10/.github/workflows/release.yaml#L52
    MSYS2_ARG_CONV_EXCL='*' \
        cl.exe \
        /nologo \
        /W4 \
        "/I${include_dir}" \
        /O2 \
        /MD \
        /LD \
        sqlite-vec.c \
        /Fe:dist/vec0.dll

    mkdir -p "${library_lib}/sqlite-vec"
    install -m 0755 \
        dist/vec0.dll \
        "${library_lib}/sqlite-vec/vec0.dll"
else
    export CPPFLAGS="${CPPFLAGS:-} -I\"${PREFIX}/include\""
    extension=so
    if [[ "${target_platform}" == osx-* ]]; then
        extension=dylib
        export LDFLAGS="${LDFLAGS:-} -Wl,-install_name,@rpath/sqlite-vec/vec0.dylib"
    fi

    make loadable
    mkdir -p "${PREFIX}/lib/sqlite-vec"
    install -m 0755 "dist/vec0.${extension}" "${PREFIX}/lib/sqlite-vec/vec0.${extension}"
fi
