@echo off

if exist src rmdir /s /q src
mkdir src
echo */ci/*> tar_excludes.txt
tar xf source.tar.gz --strip-components=1 -C src -X tar_excludes.txt

cmake -GNinja ^
  %CMAKE_ARGS% ^
  -DCMAKE_VERBOSE_MAKEFILE=ON ^
  -S src ^
  -B build_dir
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release -j 4
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release --target install
if %errorlevel% neq 0 exit %errorlevel%
