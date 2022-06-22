set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

:: Prefer Ninja, and make sure that CMAKE_GENERATOR_PLATFORM and CMAKE_GENERATOR_TOOLSET
:: environment variables (that are only working with VS generator) are not set
set CMAKE_GENERATOR=Ninja
set CMAKE_GENERATOR_PLATFORM=
set CMAKE_GENERATOR_TOOLSET=

cd %SRC_DIR%\python
bash make_sdist.sh
if errorlevel 1 exit 1

:: Without this, the setup.py fails on Windows as it tries to access
:: some location it does not have the rights to on the build machine
:: This ensure that a accessible directory is used
rmdir /s /q %SRC_DIR%\tempbuilddir
mkdir %SRC_DIR%\tempbuilddir
set TEMP=%SRC_DIR%\tempbuilddir
cd dist
set MUJOCO_PATH=%PREFIX%\Library
python -m pip install --no-deps mujoco-%PKG_VERSION%.tar.gz
if errorlevel 1 exit 1
