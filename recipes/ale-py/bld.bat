@echo on

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_CPP_LIB=ON ^
      -DBUILD_PYTHON_LIB=ON ^
      -DSDL_SUPPORT=ON ^
      ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build .
if %ERRORLEVEL% neq 0 exit 1

cmake --install --prefix $PREFIX
if %ERRORLEVEL% neq 0 exit 1

cd ..

:: see https://github.com/mgbellemare/Arcade-Learning-Environment/blob/v0.7.5/setup.py#L109-L150
set CIBUILDWHEEL=1
set "GITHUB_REF=%PKG_VERSION%"

python -m pip install . -vv
if %ERRORLEVEL% neq 0 exit 1
