#!/bin/bash

set -euo pipefail

# OpenColorIO build script following official installation instructions
# https://opencolorio.readthedocs.io/en/latest/quick_start/installation.html

# Create build directory
mkdir -p build
cd build

# following note at https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
if [[ "${target_platform}" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi


# CMake configuration with explicit flags (showing defaults from documentation)
# Common CMake Options:
cmake_args=(
    "-GNinja"
    "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=ON"

    # Feature toggles (set via env vars from recipe.yaml outputs)
    "-DOCIO_BUILD_APPS=${OCIO_BUILD_APPS:-OFF}"
    "-DOCIO_BUILD_PYTHON=${OCIO_BUILD_PYTHON:-OFF}"

    # Disabled features
    "-DOCIO_BUILD_OPENFX=OFF"
    "-DOCIO_BUILD_JAVA=OFF"
    "-DOCIO_BUILD_TESTS=OFF"
    "-DOCIO_BUILD_GPU_TESTS=OFF"
    "-DOCIO_USE_OIIO_FOR_APPS=OFF"   # OFF: would create circular dep (OIIO depends on OCIO)
    "-DOCIO_WARNING_AS_ERROR=OFF"

    # SIMD master switch
    "-DOCIO_USE_SIMD=ON"

    # Ensure the shared library uses upstream SOVERSION scheme:
    # libOpenColorIO.so.2.5.1 with SONAME libOpenColorIO.so.2.5 (+ symlinks)
    "-DOCIO_USE_SOVERSION=ON"

    # Dependency installation strategy (MISSING is the default):
    # NONE: Use system installed packages, fail if missing
    # MISSING: Prefer system, install if missing (DEFAULT)
    # ALL: Install all required packages regardless
    # ==> All dependencies come from conda — never download at build time
    "-DOCIO_INSTALL_EXT_PACKAGES=NONE"
)

# SIMD: explicitly enable per-architecture instruction sets.
# OCIO uses runtime dispatch (CPUInfo) — higher instruction sets like AVX2/AVX512
# are compiled in but only execute on CPUs that support them at runtime.
if [[ "${target_platform}" == linux-64 || "${target_platform}" == osx-64 ]]; then
    cmake_args+=(
        "-DOCIO_USE_SSE2=ON"
        "-DOCIO_USE_SSE3=ON"
        "-DOCIO_USE_SSSE3=ON"
        "-DOCIO_USE_SSE4=ON"
        "-DOCIO_USE_SSE42=ON"
        "-DOCIO_USE_AVX=ON"
        "-DOCIO_USE_AVX2=ON"
        "-DOCIO_USE_AVX512=ON"
        "-DOCIO_USE_F16C=ON"
    )
elif [[ "${target_platform}" == linux-aarch64 || "${target_platform}" == osx-arm64 ]]; then
    cmake_args+=(
        "-DOCIO_USE_SSE2NEON=ON"
    )
fi

# Headless EGL: on Linux, tools (ociolutimage, ocioconvert --gpu, …) can create
# a GL context via EGL without a running X display server.
# macOS and Windows use system GL (CGL/WGL) and do not need this.
if [[ "${target_platform}" == linux-* ]] && [[ "${OCIO_BUILD_APPS:-OFF}" == "ON" ]]; then
    cmake_args+=("-DOCIO_USE_HEADLESS=ON")
else
    cmake_args+=("-DOCIO_USE_HEADLESS=OFF")
fi

# OCIO_BUILD_DOCS=ON enables Doxygen-based docstring extraction for Python bindings.
# Notably because : "CMake Warning at src/bindings/python/CMakeLists.txt:44 (message):
# Building PyOpenColorIO with OCIO_BUILD_DOCS disabled will result in incomplete Python docstrings."

# docs/CMakeLists.txt checks for sphinx-press-theme and testresources at configure
# time via find_python_package(REQUIRED), but neither is on conda-forge and neither
# is actually used (--target install never triggers the docs ALL/Sphinx target).
# Stub both packages so cmake configure passes; the stubs are never imported.
if [[ "${OCIO_BUILD_PYTHON:-OFF}" == "ON" ]]; then
    cmake_args+=(
        "-DOCIO_BUILD_DOCS=ON"
        # Force CMake to use the host-prefix Python (PYTHON) for all Python checks.
        # In conda/rattler builds, CMake runs from the build prefix and may otherwise
        # auto-select a different Python than the one we are building PyOpenColorIO for.
        "-DPython_EXECUTABLE=${PYTHON}"
        "-DPython3_EXECUTABLE=${PYTHON}"
    )
    # Stubs go FIRST so they shadow any installed-but-broken packages (e.g. sphinx-tabs
    # fails to import against newer Sphinx despite being installed).
    mkdir -p _sphinx_stubs/sphinx_press_theme _sphinx_stubs/testresources _sphinx_stubs/sphinx_tabs
    touch _sphinx_stubs/sphinx_press_theme/__init__.py \
          _sphinx_stubs/testresources/__init__.py \
          _sphinx_stubs/sphinx_tabs/__init__.py
    export PYTHONPATH="$(pwd)/_sphinx_stubs${PYTHONPATH:+:${PYTHONPATH}}"
else
    cmake_args+=("-DOCIO_BUILD_DOCS=OFF")
fi

cmake "${cmake_args[@]}" ..

if [[ "${OCIO_BUILD_PYTHON:-OFF}" == "ON" ]]; then
    # PyOpenColorIO needs the docstring_extraction target (part of OCIO_BUILD_DOCS)
    # to generate Python docstrings from Doxygen output. However, building the
    # default ALL target would also invoke sphinx-build, which fails due to
    # missing theme packages. So we build only the PyOpenColorIO target, which pulls in docstring_extraction but skips Sphinx.
    cmake --build . --config Release --target PyOpenColorIO -j${CPU_COUNT}
    # docs/cmake_install.cmake unconditionally installs build-html/ regardless of whether sphinx ran. Create an empty placeholder so cmake --install does not error.
    mkdir -p docs/build-html
    cmake --install . --config Release
else
    cmake --build . --config Release --target install -j${CPU_COUNT}
fi

# For tools and python outputs: remove library/headers that belong to the
# opencolorio base package to avoid file overlap between outputs.
if [[ "${OCIO_BUILD_APPS}" == "ON" || "${OCIO_BUILD_PYTHON}" == "ON" ]]; then
    rm -rf  "${PREFIX}"/lib/libOpenColorIO*
    rm -rf  "${PREFIX}"/lib/cmake/OpenColorIO
    rm -rf  "${PREFIX}"/include/OpenColorIO
    rm -f   "${PREFIX}"/lib/pkgconfig/OpenColorIO*.pc
    rm -f   "${PREFIX}"/lib/libOpenColorIO*.a
    rm -rf  "${PREFIX}"/share/doc/OpenColorIO
fi
