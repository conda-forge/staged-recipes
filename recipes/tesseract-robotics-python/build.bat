@echo off

if exist src rmdir /s /q src
mkdir src
echo */ci/*> tar_excludes.txt
tar xf source.tar.gz --strip-components=1 -C src -X tar_excludes.txt

cmake -GNinja ^
  %CMAKE_ARGS% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON ^
  -DTESSERACT_ENABLE_TESTING=OFF ^
  -DTESSERACT_ENABLE_EXAMPLES=OFF ^
  -DCMAKE_VERBOSE_MAKEFILE=ON ^
  -DPYTHON_EXECUTABLE=%PYTHON% ^
  -S src/tesseract_python ^
  -B build_dir
if %errorlevel% neq 0 exit %errorlevel%
cmake --build build_dir --config Release -j 4
if %errorlevel% neq 0 exit %errorlevel%

%PYTHON% -m pip install --no-deps --ignore-installed --no-build-isolation -vvv .\build_dir\python
if %errorlevel% neq 0 exit %errorlevel%
%PYTHON% -m pip install --no-deps --ignore-installed --no-build-isolation -vvv .\src\tesseract_viewer_python
if %errorlevel% neq 0 exit %errorlevel%
