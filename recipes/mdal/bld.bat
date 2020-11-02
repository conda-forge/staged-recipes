mkdir build
if errorlevel 1 exit /b 1

cd build
if errorlevel 1 exit /b 1

cmake  ^
	-DCMAKE_BUILD_TYPE=Release  ^
	-DENABLE_TESTS=OFF ^
	-DNETCDF_PREFIX="%LIBRARY_PREFIX%" ^
	-DHDF5_ROOT="%LIBRARY_PREFIX%" ^
	-DGDAL_DIR="%LIBRARY_PREFIX%" ^
	-DGDAL_LIBRARY="%LIBRARY_PREFIX%\lib\gdal_i.lib" ^
	-DGDAL_INCLUDE_DIR="%LIBRARY_PREFIX%\include" ^
	-DLIBXML2_LIBRARIES="%LIBRARY_PREFIX%\lib\libxml2.lib" ^
	-DLIBXML2_INCLUDE_DIR="%LIBRARY_PREFIX%\include\libxml2" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
	..
if errorlevel 1 exit /b 1

cmake --build . 
if errorlevel 1 exit /b 1

copy /B mdal\*.dll %LIBRARY_BIN%
if errorlevel 1 exit /b 1

copy /B tools\*.exe %LIBRARY_BIN%
if errorlevel 1 exit /b 1
