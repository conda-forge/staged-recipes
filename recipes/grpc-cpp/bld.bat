@echo on

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp

cmake ..  ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_GFLAGS_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package"

dir %PREFIX% /S

cmake --build . --config Release --target install

if errorlevel 1 exit 1

dir %PREFIX% /S
