@echo on
setlocal EnableDelayedExpansion

REM Generate bash build script
REM Inside double quotes, ) does not close the ( ) block, so no ^ escaping needed
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo SRC_UNIX="$(cygpath '%SRC_DIR%')"
echo BUILD_UNIX="$(cygpath '%BUILD_PREFIX%')"
echo PREFIX_UNIX="$(cygpath '%PREFIX%')"
echo cd "$SRC_UNIX"
echo for dir in "$BUILD_UNIX/Library/mingw-w64/bin" "$BUILD_UNIX/mingw64/bin" "$BUILD_UNIX/Library/bin" "$BUILD_UNIX/bin"; do
echo     if [ -d "$dir" ]; then export PATH="$dir:$PATH"; fi
echo done
echo sed -i 's/        cc) toolname="gcc";;/        *-cc) toolname="gcc";;\n        cc) toolname="gcc";;/' configure
echo sed -i 's/        c++) toolname="gxx";;/        *-c++) toolname="gxx";;\n        c++) toolname="gxx";;/' configure
echo ./configure --generator=ninja --kind=shared --prefix="$PREFIX_UNIX"
echo ninja install -j"${CPU_COUNT:-1}"
) > _build.sh
endlocal

echo === Generated _build.sh: ===
type _build.sh
echo ===========================

bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
if %ERRORLEVEL% neq 0 exit /b 1
