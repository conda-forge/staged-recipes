@echo off

if exist src rmdir /s /q src
mkdir src
echo */ci/*> tar_excludes.txt
tar xf source.tar.gz --strip-components=1 -C src -X tar_excludes.txt

cmake -GNinja ^
  %CMAKE_ARGS% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON ^
  -DCMAKE_VERBOSE_MAKEFILE=ON ^
  -S src\descartes_light ^
  -B build_dir
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release -j 4
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release --target install
if %errorlevel% neq 0 exit %errorlevel%
