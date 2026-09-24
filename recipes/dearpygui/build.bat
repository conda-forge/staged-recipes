@echo ON

rmdir /S /Q thirdparty\Microsoft
rmdir /S /Q thirdparty\gl3w
rmdir /S /Q thirdparty\glfw
rmdir /S /Q thirdparty\cpython
rmdir /S /Q thirdparty\freetype

mkdir cmake-build-local
cd cmake-build-local

cmake -G "Ninja" %CMAKE_ARGS% ^
    -DMVDIST_ONLY=True ^
    -DMVDPG_VERSION=%PKG_VERSION% ^
    -DMV_PY_VERSION=%PY_VER% ^
    ..
:REM Check that the error level is not 0 then exit with that error level
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

cmake --build . --config Release
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

cd ..
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

mkdir output
mkdir output\dearpygui

copy cmake-build-local\DearPyGui\_dearpygui.pyd output\dearpygui\_dearpygui.pyd
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

%PYTHON% -m pip install . -vv
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
