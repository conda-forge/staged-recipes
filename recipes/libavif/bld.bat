mkdir build
cd build
if errorlevel 1 exit /b 1

:: Other codecs cannot be enabled because they are not on conda-forge
cmake .. -GNinja ^
-DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
-DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
-DCMAKE_INSTALL_LIBDIR=lib ^
-DCMAKE_BUILD_TYPE=Release ^
-DBUILD_SHARED_LIBS=ON ^
-DAVIF_BUILD_TESTS=ON ^
-DAVIF_CODEC_AOM=ON ^
-DAVIF_CODEC_SVT=OFF ^
-DAVIF_CODEC_DAV1D=OFF ^
-DAVIF_CODEC_LIBGAV1=OFF
if errorlevel 1 exit /b 1

ninja
if errorlevel 1 exit /b 1

.\aviftest ..\tests\data\
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1
