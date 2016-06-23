@echo off

mkdir build
cd build

set BUILD_CONFIG=Release

REM pick generator based on python version
if %PY_VER%==2.7 (
    set GENERATOR_NAME=Visual Studio 9 2008
)
if %PY_VER%==3.4 (
    set GENERATOR_NAME=Visual Studio 10 2010
)
if %PY_VER%==3.5 (
    set GENERATOR_NAME=Visual Studio 14 2015
)

REM pick architecture
if %ARCH%==64 (
	set GENERATOR_NAME=%GENERATOR_NAME% Win64
)

REM tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cmake .. -G"%GENERATOR_NAME%" ^
    -Wno-dev ^
    -DCMAKE_CONFIGURATION_TYPES:STRING="Debug;Release;MinSizeRel;RelWithDebInfo" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_TESTING=ON ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%/include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DVTK_BUILD_PYTHON_MODULE_DIR:PATH="%SP_DIR%/vtk" ^
    -DVTK_ENABLE_VTKPYTHON:BOOL="0" ^
    -DVTK_WRAP_PYTHON:BOOL="1" ^
    -DVTK_PYTHON_VERSION:STRING="%PY_VER%" ^
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="%SP_DIR%" ^
    -DModule_vtkWrappingPythonCore:BOOL="0" ^
    -DINSTALL_BIN_DIR:PATH="%LIBRARY_BIN%" ^
    -DINSTALL_LIB_DIR:PATH="%LIBRARY_LIB%" ^
    -DINSTALL_INC_DIR:PATH="%LIBRARY_INC%" ^
    -DINSTALL_MAN_DIR:PATH="%LIBRARY_PREFIX%/man" ^
    -DINSTALL_PKGCONFIG_DIR:PATH="%LIBRARY_PREFIX%/pkgconfig"
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config %BUILD_CONFIG%
if errorlevel 1 exit 1
