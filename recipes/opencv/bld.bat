@echo off

mkdir build
cd build

rem Python 3.x not supported by OpenCV 2.x
if %ARCH%==32 (
  if %PY_VER% LSS 3 (
    set CMAKE_GENERATOR="Visual Studio 9 2008"
    set CMAKE_CONFIG="Release"
	set OPENCV_ARCH=x86
	set OPENCV_VC=vc9
  )
)
if %ARCH%==64 (
  if %PY_VER% LSS 3 (
    set CMAKE_GENERATOR="Visual Studio 9 2008 Win64"
    set CMAKE_CONFIG="Release"
	set OPENCV_ARCH=x64
	set OPENCV_VC=vc9
  )
)

rem I had to take out the PNG_LIBRARY because it included
rem a Windows path which caused it to be wrongly escaped
rem and thus an error. Somehow though, CMAKE still finds
rem the correct png library...
cmake .. -G%CMAKE_GENERATOR%                        ^
    -DBUILD_TESTS=0                                 ^
    -DBUILD_DOCS=0                                  ^
    -DBUILD_PERF_TESTS=0                            ^
    -DBUILD_ZLIB=1                                  ^
    -DBUILD_TIFF=1                                  ^
    -DBUILD_PNG=1                                   ^
    -DBUILD_OPENEXR=1                               ^
    -DBUILD_JASPER=1                                ^
    -DBUILD_JPEG=1                                  ^
    -DPYTHON_EXECUTABLE="%PYTHON%"                  ^
    -DPYTHON_INCLUDE_PATH="%PREFIX%\include"        ^
    -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib"   ^
    -DPYTHON_PACKAGES_PATH="%SP_DIR%"               ^
    -DWITH_CUDA=0                                   ^
    -DWITH_OPENCL=0                                 ^
    -DWITH_OPENNI=0                                 ^
    -DWITH_FFMPEG=1                                 ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1

rem Let's just move the files around to a more sane structure (flat)
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\bin\*.dll" "%LIBRARY_BIN%"
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\bin\*.exe" "%LIBRARY_BIN%"
move "%LIBRARY_PREFIX%\%OPENCV_ARCH%\%OPENCV_VC%\lib\*.lib" "%LIBRARY_LIB%"
rmdir "%LIBRARY_PREFIX%\%OPENCV_ARCH%" /S /Q

rem By default cv.py is installed directly in site-packages
rem Therefore, we have to copy all of the dlls directly into it!
xcopy "%LIBRARY_BIN%\opencv*.dll" "%SP_DIR%"

