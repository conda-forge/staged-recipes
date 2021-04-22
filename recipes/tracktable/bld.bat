@REM Build Windows package from tracktable source
set "CXX=cl.exe"
set "CC=cl.exe"
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