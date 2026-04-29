mkdir build
cd build


if "%WITH_PYTHON%"=="" (
    set "WITH_PYTHON=OFF"
)

if "%MULTI_STAGE_BUILD%"=="" (
    set "MULTI_STAGE_BUILD=OFF"
)


set CONFIGURATION=Release

cmake .. -G "NMake Makefiles" ^
         -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -DPython_EXECUTABLE="%PYTHON%" ^
         -DWITH_LOG="OFF" ^
         -DWITH_PYTHON=%WITH_PYTHON% ^
         -DMULTI_STAGE_BUILD=%MULTI_STAGE_BUILD% ^
         -DWITH_BIN=OFF


if errorlevel 1 exit 1

nmake all
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
