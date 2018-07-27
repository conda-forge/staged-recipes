
if %PY3K% equ 1 (
  set BUILD_PYTHON="-DBUILD_PYTHON_INTERFACE=ON"
) else (
  set BUILD_PYTHON="-DBUILD_PYTHON2_INTERFACE=ON"
)

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%PREFIX% -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" %BUILD_PYTHON%" -G "Ninja" ..
ninja
ninja install

move %LIBRARY_PREFIX%\python\_helics.pyd %SP_DIR%
move %LIBRARY_PREFIX%\python\helics.py %SP_DIR%

popd
