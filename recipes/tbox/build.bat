@echo on
setlocal EnableDelayedExpansion

REM Generate bash build script
REM ) inside double quotes doesn't need escaping, but ) inside single quotes does (^))
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo SRC_UNIX="$(cygpath '%SRC_DIR%')"
echo BUILD_UNIX="$(cygpath '%BUILD_PREFIX%')"
echo cd "$SRC_UNIX"
echo for dir in "$BUILD_UNIX/Library/mingw-w64/bin" "$BUILD_UNIX/mingw64/bin" "$BUILD_UNIX/Library/bin" "$BUILD_UNIX/bin"; do
echo     if [ -d "$dir" ]; then export PATH="$dir:$PATH"; fi
echo done
echo sed -i 's/        cc^) toolname="gcc";;/        *-cc^) toolname="gcc";;\n        cc^) toolname="gcc";;/' configure
echo sed -i 's/        c++^) toolname="gxx";;/        *-c++^) toolname="gxx";;\n        c++^) toolname="gxx";;/' configure
echo export REMOVE_LIB_PREFIX=1
echo ./configure --generator=gmake --kind=shared --prefix="${PREFIX}"
echo make -j"${CPU_COUNT:-1}"
echo make install
) > _build.sh
endlocal

set REMOVE_LIB_PREFIX=1

if not exist "%PREFIX%\Library\lib" mkdir "%PREFIX%\Library\lib"
if not exist "%PREFIX%\Library\include" mkdir "%PREFIX%\Library\include"
if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"

call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" _build.sh

if %ERRORLEVEL% neq 0 exit 1
