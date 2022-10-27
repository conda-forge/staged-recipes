pushd test

cmake . -D CMAKE_BUILD_TYPE="Release"
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%

Release\hello_hpx.exe
if %errorlevel% neq 0 exit /b %errorlevel%

popd
