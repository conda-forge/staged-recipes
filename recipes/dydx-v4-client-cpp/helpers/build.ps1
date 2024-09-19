$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-client, _conda-logs

# Check if the symbol exists in the .lib
$libSymbols = dumpbin /linkermember:1 $PREFIX\Library\lib\dydx_v4_proto.lib | Select-String -Pattern "cosmos::base::v1beta1"
if (-not $libSymbols) {
  Write-Output "Symbol 'cosmos::base::v1beta1' not found in $PREFIX\Library\lib\dydx_v4_proto.lib"
  exit 1
}

Push-Location _conda-build-client
  cmake "$env:SRC_DIR/v4-client-cpp" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="${env:PREFIX}/lib" `
    -DCMAKE_INSTALL_PREFIX="${env:PREFIX}" `
    -DBUILD_SHARED_LIBS=ON `
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON `
    -G Ninja
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target dydx_v4_client_lib -- -j"$env:CPU_COUNT"
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --install . --component client
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }
Pop-Location

Push-Location _conda-build-client
  cmake --build . --target dydx_v4_client_lib_tests -- -j"$env:CPU_COUNT"
  .\lib\dydx_v4_client_lib_tests
  Copy-Item lib/dydx_v4_client_lib_tests "$env:PREFIX/bin"
  icacls "$env:PREFIX/bin/dydx_v4_client_lib_tests" /grant Everyone:F
Pop-Location
