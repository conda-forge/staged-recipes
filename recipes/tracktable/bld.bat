@REM Build Windows package from tracktable source

REM This is a fix for a problem in Azure+CMake where CMake is finding a
REM different compiler (GCC, etc.) instead of MSVC
REM See: https://github.com/conda-forge/conda-forge.github.io/issues/714
@echo.
@echo CC: "%CC%" -^> "cl.exe"
set CC=cl.exe
@echo CXX: "%CXX%" -^> "cl.exe"
set CXX=cl.exe

echo ENVIRONMENT_VARS
set
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
cmake^
 -G "Ninja"^
 -DBOOST_ROOT:PATH=%BUILD_PREFIX%^
 -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX%^
 -DCMAKE_BUILD_TYPE="Release"^
 -DBUILD_DOCUMENTATION=OFF^
 -DPython3_EXECUTABLE:FILEPATH=%PYTHON%^
 -DPython3_ROOT_DIR:PATH=%PREFIX%^
 -DCMAKE_CXX_COMPILER=cl.exe^
 %SRC_DIR%^
 -LA
if errorlevel 1 exit 1
ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
cd %PREFIX%
%PYTHON% %SRC_DIR%/packaging/setup-generic.py install
if errorlevel 1 exit 1
