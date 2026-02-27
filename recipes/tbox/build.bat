@echo on
setlocal EnableDelayedExpansion

if not defined CPU_COUNT set "CPU_COUNT=1"

REM Generate bash build script
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo SRC_UNIX="$(cygpath '%SRC_DIR%'^)"
echo BUILD_UNIX="$(cygpath '%BUILD_PREFIX%'^)"
echo PREFIX_UNIX="$(cygpath '%PREFIX%'^)"
echo cd "$SRC_UNIX"
echo # Add mingw-w64 gcc to PATH
echo for dir in "$BUILD_UNIX/Library/mingw-w64/bin" "$BUILD_UNIX/mingw64/bin" "$BUILD_UNIX/Library/bin" "$BUILD_UNIX/bin"; do
echo     if [ -d "$dir" ]; then export PATH="$dir:$PATH"; fi
echo done
echo echo "gcc location: $(command -v gcc 2^>/dev/null ^|^| echo not found^)"
echo ./configure --kind=shared --prefix="$PREFIX_UNIX"
echo make -j%CPU_COUNT%
echo make install PREFIX="$PREFIX_UNIX"
) > _build.sh
endlocal

echo === Generated _build.sh: ===
type _build.sh
echo ===========================

bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
if %ERRORLEVEL% neq 0 exit /b 1
