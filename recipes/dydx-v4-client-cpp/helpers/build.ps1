$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-client, _conda-logs

Invoke-Expression "patch -p0 -i ${env:RECIPE_DIR}/patches/xxxx-cmake-client-lib.patch"

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

Invoke-Expression "patch -p0 -i ${env:RECIPE_DIR}/patches/xxxx-cmake-tests.patch"

Push-Location _conda-build-protocol
  cmake --build . --target dydx_v4_client_lib_static -- -j"$env:CPU_COUNT"
Pop-Location

Push-Location _conda-build-client
  Copy-Item "$env:SRC_DIR/_conda-build-protocol/lib/libdydx_v4_client_lib_static.a" lib/proto
  cmake --build . --target dydx_v4_client_lib_tests -- -j"$env:CPU_COUNT"
  .\lib\dydx_v4_client_lib_tests
  Copy-Item lib/dydx_v4_client_lib_tests "$env:PREFIX/bin"
  icacls "$env:PREFIX/bin/dydx_v4_client_lib_tests" /grant Everyone:F
Pop-Location
