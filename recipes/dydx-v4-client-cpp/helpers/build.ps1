$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-client, _conda-logs

$LIB = Get-ChildItem -Path "$env:PREFIX" -Filter "*.lib" -Recurse | Where-Object { $_.Name -match "dydx_v4_proto"}
$coinMutableDenom = dumpbin /linkermember:1 $LIB | Select-String -Pattern "\?mutable_denom@Coin"
if (-not $coinMutableDenom) {
    Write-Output "Coin::mutable_denom not found in $LIB"
    exit 1
} else {
    Write-Output "Found Coin::mutable_denom in $LIB"
    $coinMutableDenom | ForEach-Object { Write-Output $_.Line }
}

$HEADER = Get-ChildItem -Path "$env:PREFIX" -Filter "Coin.pb.h" -Recurse
# Check that Coin mutable_denom is exported in the header file
$coinMutableDenom = Get-Content $HEADER.FullName | Select-String -Pattern "Coin::mutable_denom"
if (-not $coinMutableDenom) {
    Write-Output "Coin::mutable_denom not found in $HEADER"
    exit 1
} else {
    Write-Output "Found Coin::mutable_denom in $HEADER"
    $coinMutableDenom | ForEach-Object { Write-Output $_.Line }
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
