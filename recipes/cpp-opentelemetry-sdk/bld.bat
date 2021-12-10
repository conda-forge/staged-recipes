@echo on

mkdir build-cpp
if errorlevel 1 exit 1

# Release tarballs do not contain the required Protobuf definitions.
robocopy /S /E %LIBRARY_PREFIX%\share\opentelemetry\opentelemetry-proto\opentelemetry .\third_party\opentelemetry-proto\opentelemetry

cd build-cpp
cmake .. ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DBUILD_TESTING=OFF ^
      -DWITH_API_ONLY=OFF ^
      -DWITH_ETW=OFF ^
      -DWITH_EXAMPLES=OFF ^
      -DWITH_OTLP=ON ^
      -DWITH_OTLP_GRPC=ON

cmake --build . --config Release --target install
if errorlevel 1 exit 1
