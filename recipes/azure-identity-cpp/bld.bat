@echo on

set "AZURE_SDK_DISABLE_AUTO_VCPKG=ON"

cd sdk\identity\azure-identity

mkdir build
cd build
cmake %CMAKE_ARGS% ^
  -G Ninja ^
  -D BUILD_SHARED_LIBS=ON ^
  -D BUILD_TRANSPORT_WINHTTP=ON ^
  ..
if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install --config Release
if %ERRORLEVEL% neq 0 exit 1
