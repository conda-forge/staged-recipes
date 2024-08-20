@echo off

rem This batch file builds the BLST library.
call build.bat -dll flavor=mingw64

mkdir "%PREFIX%\lib"
copy blst.dll %PREFIX%\lib\blst.dll
:: copy libblst.dll %PREFIX%\lib\libblst.so."%PKG_MAJOR_VERSION%"
:: copy libblst.dll %PREFIX%\lib\libblst.so."%PKG_VERSION%"

pushd bindings\python
  %PYTHON% run.me
  mkdir "%PREFIX%\lib\python%PY_VER%\site-packages"
  copy blst.py "%PREFIX%\lib\python%PY_VER%\site-packages\blst.py"
  copy _blst.pyd "%PREFIX%\lib\python%PY_VER%\site-packages\_blst.pyd"
popd
