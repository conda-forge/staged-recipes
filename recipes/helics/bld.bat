
if %PY3K% equ 1 (
  set BUILD_PYTHON="-DBUILD_PYTHON_INTERFACE=ON"
  set PYTHON_VERSION="%PY_VER%m"
) else (
  set BUILD_PYTHON="-DBUILD_PYTHON2_INTERFACE=ON"
  set PYTHON_VERSION="%PY_VER%"
)

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_INCLUDE_DIR=%PREFIX%\include\python%PYTHON_VERSION%\ -DPYTHON_LIBRARY=%PREFIX%\lib\python%PYTHON_VERSION%\libpython%PYTHON_VERSION%.dll -DCMAKE_PREFIX_PATH=%PREFIX% -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" %BUILD_PYTHON%" -G "Ninja" ..
ninja
ninja install

move %LIBRARY_PREFIX%\python\_helics.pyd %SP_DIR%
move %LIBRARY_PREFIX%\python\helics.py %SP_DIR%

popd
