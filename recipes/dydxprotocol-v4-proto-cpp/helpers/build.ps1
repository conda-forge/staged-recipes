$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"
$env:PATH = "${env:PREFIX}/Library/bin;$env:PATH"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-protocol, _conda-logs

Push-Location _conda-build-protocol

  $_PREFIX = $env:PREFIX -replace '\\', '/'

  cmake "$env:SRC_DIR/v4-client-cpp" `
    "${env:CMAKE_ARGS}" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="$_PREFIX/lib;$_PREFIX/Library/lib" `
    -DCMAKE_INSTALL_PREFIX="$_PREFIX/Library" `
    -DBUILD_SHARED_LIBS=ON `
    -DCMAKE_VERBOSE_MAKEFILE=ON `
    -G Ninja
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target dydx_v4_proto_obj -- -j"$env:CPU_COUNT" > $env:SRC_DIR/_conda-logs/build.log
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target dydx_v4_proto -- -j"$env:CPU_COUNT"
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target copy_version_to_generic_dll -- -j"$env:CPU_COUNT"
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --install . --component protocol
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }
Pop-Location
