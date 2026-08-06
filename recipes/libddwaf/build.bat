@echo on
setlocal enabledelayedexpansion

rem remove bundled dependencies
copy NUL third_party\CMakeLists.txt
del /s /q /f src\vendor\re2 src\vendor\utf8proc

rem other bundled dependencies:
rem - fmt (patched to use custom namespace)
rem - libinjection, lua-aho-corasick, radixlib

cmake -S. -Bbuild ^
  %CMAKE_ARGS% ^
  -GNinja ^
  -DLIBDDWAF_BUILD_STATIC=OFF ^
  -DLIBDDWAF_TEST_COVERAGE=OFF ^
  -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

ninja -C build
if errorlevel 1 exit 1
ninja -C build test
if errorlevel 1 exit 1
ninja -C build install
if errorlevel 1 exit 1
