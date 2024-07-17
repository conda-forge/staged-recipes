@echo off
REM Ensure the build directory is clean
IF EXIST build (
    rmdir /s /q build
)
mkdir build
cd build

REM Configure CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="%PYTHON%" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON %SRC_DIR%
if errorlevel 1 exit /b 1

REM Build the project
cmake --build . --config Release
if errorlevel 1 exit /b 1

REM Install the project
cmake --install . --prefix %PREFIX%
if errorlevel 1 exit /b 1
