
if %PY3K% equ 1 (
  set BUILD_PYTHON="-DBUILD_PYTHON_INTERFACE=ON"
  set PYTHON_VERSION="%PY_VER%m"
) else (
  set BUILD_PYTHON="-DBUILD_PYTHON2_INTERFACE=ON"
  set PYTHON_VERSION="%PY_VER%"
)

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

set PY_VER_NO_DOT=%PY_VER:.=%

cmake -DCMAKE_BUILD_TYPE=Release -DCOMPILER_CAN_DO_CPP_11=ON -DCXX_FLAGS="-std=c++11" -DPYTHON_LIBRARY="%PREFIX%\libs\python%PY_VER_NO_DOT%.lib"  -DPYTHON_INCLUDE_DIR="%PREFIX%\include" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" %BUILD_PYTHON%" -G "Ninja" ..
ninja
ninja install

move %LIBRARY_PREFIX%\python\_helics.pyd %SP_DIR%
move %LIBRARY_PREFIX%\python\helics.py %SP_DIR%

popd
