@echo on
setlocal EnableDelayedExpansion

REM Generate bash build script
REM ) inside double quotes doesn't need escaping, but ) inside single quotes does (^))
setlocal DisableDelayedExpansion
(
echo #!/bin/bash
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
