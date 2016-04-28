REM pick build configuration
set BUILD_CONFIG=Release

REM pick generator based on python version
if %PY_VER%==2.6 (
    set GENERATOR_NAME=Visual Studio 9 2008
)
if %PY_VER%==2.7 (
    set GENERATOR_NAME=Visual Studio 9 2008
)
if %PY_VER%==3.3 (
    set GENERATOR_NAME=Visual Studio 10 2010
)
if %PY_VER%==3.4 (
    set GENERATOR_NAME=Visual Studio 10 2010
)
if %PY_VER%==3.5 (
    set GENERATOR_NAME=Visual Studio 14 2015
)

REM pick architecture
set ARCH_NAME=x86
if %ARCH%==64 (
	set GENERATOR_NAME=%GENERATOR_NAME% Win64
	set ARCH_NAME=x86_64
)

REM tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

REM generate visual studio solution
cmake . -G"%GENERATOR_NAME%" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
    -DGDCM_BUILD_APPLICATIONS:BOOL=ON ^
    -DGDCM_BUILD_SHARED_LIBS:BOOL=ON ^
    -DGDCM_USE_PVRG:BOOL=ON ^
    ^
    -DGDCM_USE_VTK:BOOL=OFF ^
    ^
    -DGDCM_WRAP_PYTHON:BOOL=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DPYTHON_LIBRARY=%PYTHON_LIBRARY% ^
    -DPYTHON_INCLUDE_DIR=%PREFIX%\include ^
    ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_RPATH:STRING=%LIBRARY_LIB% ^
    -DGDCM_INSTALL_BIN_DIR=%LIBRARY_BIN% ^
    -DGDCM_INSTALL_LIB_DIR=%LIBRARY_LIB% ^
    -DGDCM_INSTALL_DATA_DIR=%LIBRARY_PREFIX% ^
    -DGDCM_INSTALL_INCLUDE_DIR=%LIBRARY_INC% ^
    -DGDCM_INSTALL_NO_DOCUMENTATION:BOOL=ON ^
    -DGDCM_INSTALL_NO_DEVELOPMENT:BOOL=ON ^
    -DGDCM_INSTALL_PYTHONMODULE_DIR:PATH=%SP_DIR%
    
if errorlevel 1 exit 1

REM build
cmake --build . --target ALL_BUILD --config %BUILD_CONFIG%
cmake --build . --target INSTALL --config %BUILD_CONFIG%
if errorlevel 1 exit 1

exit /b 0