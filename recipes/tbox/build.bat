@echo on
setlocal EnableDelayedExpansion

set "MSYSTEM=MINGW64"
if not defined CPU_COUNT set "CPU_COUNT=1"

echo === xmake build.bat starting ===

if not exist configure (
    echo ERROR: configure not found after extraction
    dir /b
    exit /b 1
)

REM Find gcc from m2w64-gcc package
set "GCC_DIR="
for /r "%BUILD_PREFIX%" %%f in (gcc.exe) do (
    if not defined GCC_DIR set "GCC_DIR=%%~dpf"
)
if not defined GCC_DIR (
    for /r "%PREFIX%" %%f in (gcc.exe) do (
        if not defined GCC_DIR set "GCC_DIR=%%~dpf"
    )
)
if defined GCC_DIR (
    echo Found gcc at: !GCC_DIR!
) else (
    echo WARNING: gcc.exe not found in prefix directories
)

REM Generate build script for MSYS2 bash
REM Temporarily disable delayed expansion so ! in shebang is preserved
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo.
echo PREFIX_UNIX=$(cygpath "$PREFIX"^)
echo SRC_UNIX=$(cygpath "$SRC_DIR"^)
echo BUILD_PREFIX_UNIX=$(cygpath "$BUILD_PREFIX"^)
echo cd "$SRC_UNIX"
echo.
echo # Add mingw-w64 gcc directories to PATH
echo for dir in "$BUILD_PREFIX_UNIX/Library/mingw-w64/bin" "$BUILD_PREFIX_UNIX/mingw64/bin" "$BUILD_PREFIX_UNIX/Library/bin" "$BUILD_PREFIX_UNIX/bin"; do
echo     if [ -d "$dir" ]; then
echo         echo "Adding to PATH: $dir"
echo         export PATH="$dir:$PATH"
echo     fi
echo done
echo.
echo echo "PATH=$PATH"
echo echo "gcc location: $(command -v gcc 2^>/dev/null ^|^| echo not found^)"
echo echo "cc location: $(command -v cc 2^>/dev/null ^|^| echo not found^)"
echo.
echo ./configure --prefix="$PREFIX_UNIX"
echo make -j%CPU_COUNT%
echo make install PREFIX="$PREFIX_UNIX"
) > _build.sh
endlocal

echo === Generated _build.sh: ===
type _build.sh
echo ===========================

REM Run via MSYS2 bash (cd to SRC_DIR first since bash -l changes cwd to ~)
bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo === Build completed successfully ===
