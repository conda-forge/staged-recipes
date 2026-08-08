@echo off
setlocal EnableDelayedExpansion

mkdir build
cd build

rem Feature toggles (set via env vars from recipe.yaml outputs)
rem   OCIO_BUILD_APPS   — ON for opencolorio-tools, OFF otherwise
rem   OCIO_BUILD_PYTHON — ON for pyopencolorio,     OFF otherwise

rem SIMD: explicitly enable per-architecture instruction sets.
rem OCIO uses runtime dispatch (CPUInfo) — higher instruction sets like AVX2/AVX512
rem are compiled in but only execute on CPUs that support them at runtime.
set "CMAKE_SIMD="
if "%target_platform%"=="win-64" (
    set "CMAKE_SIMD=-DOCIO_USE_SSE2=ON -DOCIO_USE_SSE3=ON -DOCIO_USE_SSSE3=ON -DOCIO_USE_SSE4=ON -DOCIO_USE_SSE42=ON -DOCIO_USE_AVX=ON -DOCIO_USE_AVX2=ON -DOCIO_USE_AVX512=ON -DOCIO_USE_F16C=ON"
)
if "%target_platform%"=="win-arm64" (
    set "CMAKE_SIMD=-DOCIO_USE_SSE2NEON=ON"
)

rem Key cmake flags (inline rem not possible inside ^ continuations):
rem   OCIO_USE_OIIO_FOR_APPS=OFF        OFF: otherwise would create circular dep (OIIO depends on OCIO)
rem   OCIO_USE_HEADLESS=OFF             Windows uses WGL for GL context creation.
rem                                     EGL/headless is Linux-specific.
rem   OCIO_USE_SOVERSION=ON             Ensure the shared library uses upstream SOVERSION scheme:
rem                                     Unix: creates libOpenColorIO.so.2.5.1 with SONAME
rem                                     libOpenColorIO.so.2.5 (+ symlinks).
rem                                     No-op on Windows — DLL stays OpenColorIO.dll.
rem   OCIO_INSTALL_EXT_PACKAGES=NONE    All dependencies come from conda — never download at build time

rem OCIO_BUILD_DOCS=ON enables Doxygen-based docstring extraction for Python bindings.
rem Notably because : "CMake Warning at src/bindings/python/CMakeLists.txt:44 (message):
rem Building PyOpenColorIO with OCIO_BUILD_DOCS disabled will result in incomplete Python docstrings."

rem docs/CMakeLists.txt checks for sphinx-press-theme and testresources at configure
rem time via find_python_package(REQUIRED), but neither is on conda-forge and neither
rem is actually used (--target install never triggers the docs ALL/Sphinx target).
rem Stub both packages so cmake configure passes; the stubs are never imported.
set "OCIO_BUILD_DOCS=OFF"
set "CMAKE_PYTHON_HINTS="
if "%OCIO_BUILD_PYTHON%"=="ON" (
    set "OCIO_BUILD_DOCS=ON"
    rem 1) Force CMake to use the host-prefix Python (PYTHON) for all Python checks.
    rem In conda/rattler builds, CMake runs from the build prefix and may otherwise
    rem auto-select a different Python than the one we are building PyOpenColorIO for.
    rem 2) Also force Python install destination to the active Windows site-packages.
    rem OCIO defaults to CMAKE_INSTALL_LIBDIR/site-packages on WIN32, which is wrong
    rem when CMAKE_INSTALL_PREFIX is set to %LIBRARY_PREFIX% for C/C++ outputs.
    set "CMAKE_PYTHON_HINTS=-DPython_EXECUTABLE=%PYTHON% -DPython3_EXECUTABLE=%PYTHON% -DPYTHON_VARIANT_PATH=%PREFIX%\Lib\site-packages"
    rem Stubs go FIRST so they shadow any installed-but-broken packages (e.g. sphinx-tabs
    rem fails to import against newer Sphinx despite being installed).
    md _sphinx_stubs\sphinx_press_theme 2>nul
    copy nul "_sphinx_stubs\sphinx_press_theme\__init__.py" >nul
    md _sphinx_stubs\testresources 2>nul
    copy nul "_sphinx_stubs\testresources\__init__.py" >nul
    md _sphinx_stubs\sphinx_tabs 2>nul
    copy nul "_sphinx_stubs\sphinx_tabs\__init__.py" >nul
    if defined PYTHONPATH (
        set "PYTHONPATH=%CD%\_sphinx_stubs;%PYTHONPATH%"
    ) else (
        set "PYTHONPATH=%CD%\_sphinx_stubs"
    )
)

rem On Windows, use the generator selected by the activated toolchain (no Ninja as it fails)
cmake ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DOCIO_BUILD_APPS=%OCIO_BUILD_APPS% ^
    -DOCIO_BUILD_PYTHON=%OCIO_BUILD_PYTHON% ^
    %CMAKE_PYTHON_HINTS% ^
    -DOCIO_BUILD_OPENFX=OFF ^
    -DOCIO_BUILD_JAVA=OFF ^
    -DOCIO_BUILD_TESTS=OFF ^
    -DOCIO_BUILD_GPU_TESTS=OFF ^
    -DOCIO_BUILD_DOCS=%OCIO_BUILD_DOCS% ^
    -DOCIO_USE_OIIO_FOR_APPS=OFF ^
    -DOCIO_WARNING_AS_ERROR=OFF ^
    -DOCIO_USE_SIMD=ON ^
    %CMAKE_SIMD% ^
    -DOCIO_USE_HEADLESS=OFF ^
    -DOCIO_USE_SOVERSION=ON ^
    -DOCIO_INSTALL_EXT_PACKAGES=NONE ^
    ..
if errorlevel 1 exit 1

if "%OCIO_BUILD_PYTHON%"=="ON" (
    rem PyOpenColorIO needs the docstring_extraction target (part of OCIO_BUILD_DOCS)
    rem to generate Python docstrings from Doxygen output. However, building the
    rem default ALL target would also invoke sphinx-build, which fails due to
    rem missing theme packages. So we build only the PyOpenColorIO target, which pulls in docstring_extraction but skips Sphinx.
    cmake --build . --config Release --target PyOpenColorIO -j %CPU_COUNT%
    if errorlevel 1 exit 1
    rem docs/cmake_install.cmake unconditionally installs build-html/ regardless of whether sphinx ran. Create an empty placeholder so cmake --install does not error.
    if not exist docs\build-html md docs\build-html
    cmake --install . --config Release
    if errorlevel 1 exit 1
) else (
    cmake --build . --config Release --target install -j %CPU_COUNT%
    if errorlevel 1 exit 1
)

rem For tools and python outputs: remove library/headers that belong to the
rem opencolorio base package to avoid file overlap between outputs.
if "%OCIO_BUILD_APPS%"=="ON" goto cleanup
if "%OCIO_BUILD_PYTHON%"=="ON" goto cleanup
goto :eof

:cleanup
del /f /q "%LIBRARY_BIN%\OpenColorIO*.dll" 2>nul
del /f /q "%LIBRARY_LIB%\OpenColorIO*.lib" 2>nul
if exist "%LIBRARY_LIB%\cmake\OpenColorIO" rmdir /s /q "%LIBRARY_LIB%\cmake\OpenColorIO"
if exist "%LIBRARY_INC%\OpenColorIO" rmdir /s /q "%LIBRARY_INC%\OpenColorIO"
del /f /q "%LIBRARY_LIB%\pkgconfig\OpenColorIO*.pc" 2>nul
if exist "%LIBRARY_PREFIX%\share\doc\OpenColorIO" rmdir /s /q "%LIBRARY_PREFIX%\share\doc\OpenColorIO"
