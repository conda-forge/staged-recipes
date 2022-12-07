@echo on

mkdir build
cd build

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_CPP_LIB=ON ^
    -DBUILD_PYTHON_LIB=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DPython3_EXECUTABLE=%PYTHON% ^
    -DSDL_SUPPORT=ON ^
    -DZLIB_LIBRARY=%LIBRARY_LIB%\zlib.lib ^
    -DZLIB_INCLUDE_DIR=%LIBRARY_INC% ^
    ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build .
if %ERRORLEVEL% neq 0 exit 1

cmake --install . --prefix $PREFIX
if %ERRORLEVEL% neq 0 exit 1

cd ..

:: see https://github.com/mgbellemare/Arcade-Learning-Environment/blob/v0.7.5/setup.py#L109-L150
set CIBUILDWHEEL=1
set "GITHUB_REF=%PKG_VERSION%"

%PYTHON% -m pip install .
if %ERRORLEVEL% neq 0 exit 1
