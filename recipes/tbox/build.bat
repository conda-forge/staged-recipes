@echo on
setlocal EnableDelayedExpansion

REM Generate bash build script
REM ) inside double quotes doesn't need escaping, but ) inside single quotes does (^))
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
echo set -euxo pipefail
echo cd "$SRC_DIR"
echo sed -i 's/        cc^) toolname="gcc";;/        *-cc^) toolname="gcc";;\n        cc^) toolname="gcc";;/' configure
echo sed -i 's/        c++^) toolname="gxx";;/        *-c++^) toolname="gxx";;\n        c++^) toolname="gxx";;/' configure
echo export REMOVE_LIB_PREFIX=1
echo ./configure --generator=gmake --kind=shared --prefix="${PREFIX}"
echo make -j"${CPU_COUNT:-1}"
echo make install
) > _build.sh
endlocal

echo === Generated _build.sh: ===
type _build.sh
echo ===========================

bash -lc "cd '%SRC_DIR%' && chmod +x _build.sh && ./_build.sh"
if %ERRORLEVEL% neq 0 exit /b 1
