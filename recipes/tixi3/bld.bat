mkdir build
cd build

REM Configure step
cmake -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
 -DBUILD_SHARED_LIBS=ON ^
 -DCMAKE_SYSTEM_PREFIX_PATH="%LIBRARY_PREFIX%" ^
 -DLIBXML2_LIBRARY="%LIBRARY_PREFIX%\lib\libxml2s.lib" ^
 -DLIBXSLT_LIBRARIES="%LIBRARY_PREFIX%\lib\libxslts.lib" ^
 -DTIXI_ENABLE_FORTRAN=ON ^
 ..
if errorlevel 1 exit 1

REM Build step 
cmake --build . --config Release --verbose
if errorlevel 1 exit 1

REM Install step
cmake --install . --config Release
if errorlevel 1 exit 1

REM install python packages
mkdir %SP_DIR%\tixi3
echo. 2> %SP_DIR%\tixi3\__init__.py
copy lib\tixi3wrapper.py %SP_DIR%\tixi3\

REM The egg-info file is necessary because some packages,
REM might require tigl3 in their setup.py.
REM See https://setuptools.readthedocs.io/en/latest/pkg_resources.html#workingset-objects

set egg_info=%SP_DIR%\tixi3-%PKG_VERSION%.egg-info
echo>%egg_info% Metadata-Version: 2.1
echo>>%egg_info% Name: tixi3
echo>>%egg_info% Version: %PKG_VERSION%
echo>>%egg_info% Summary: Fast and simple XML interface library
echo>>%egg_info% Platform: UNKNOWN
