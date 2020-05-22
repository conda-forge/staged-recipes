# call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
mkdir build
cd build
cmake ..
ninja install
if errorlevel 1 exit 1
