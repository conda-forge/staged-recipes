:: Build step
mkdir build_libjpeg
cd  build_libjpeg

cmake -G "NMake Makefiles" ^
	-D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-D CMAKE_BUILD_TYPE=Release ^
	-D ENABLE_STATIC=1 ^
	-D ENABLE_SHARED=1 ^
	-D NASM=yasm ^
	-D WITH_12BIT=1 ^
	-D CMAKE_RELEASE_POSTFIX=12 ^
	-D CMAKE_EXECUTABLE_SUFFIX=12.exe ^
    -D CMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%\jpeg12" ^
    -D CMAKE_INSTALL_DOCDIR="%LIBRARY_PREFIX%\share\doc\libjpeg-turbo12" ^
	%SRC_DIR%

if errorlevel 1 exit 1

jom -j%CPU_COUNT%
if errorlevel 1 exit 1

:: Install step
jom install
if errorlevel 1 exit 1
