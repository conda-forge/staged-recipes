:: @echo off

set CC=gcc
set "AS=gcc -S"
:: set "AS=ml64 /nologo /c /Cp /Cx /Zi"
call build.bat -shared
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

mkdir "%PREFIX%\Library\lib"
copy blst-%PKG_MAJOR_VERSION%.dll %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.dll
copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst-%PKG_MAJOR_VERSION%.lib
copy blst-%PKG_MAJOR_VERSION%.lib %PREFIX%\Library\lib\blst.lib

copy blst.h %PREFIX%\Library\include\blst.h
copy blst_aux.h %PREFIX%\Library\include\blst/blst_aux.h

pushd %SRC_DIR%\bindings\python
  set CXX=g++
  type run.me
  %PYTHON% run.me
popd
