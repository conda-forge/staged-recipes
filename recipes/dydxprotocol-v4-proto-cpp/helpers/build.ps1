$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"
$env:LD_LIBRARY_PATH = "${env:PREFIX}/lib"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-protocol, _conda-logs

Push-Location _conda-build-protocol

  $gccPath = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *-gcc.exe | Select-Object -First 1
  $gxxPath = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *-g++.exe | Select-Object -First 1

  if ($null -eq $gxxPath) {
      $gxxPath = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *-g++.exe | Select-Object -First 1
  }

  Write-Output "g++ found at: $gxxPath"
  Write-Output "gcc found at: $gccPath"

  $env:PROTOBUF_LIB_DIR = "${PREFIX}/lib"

  cmake "$env:SRC_DIR/v4-client-cpp" `
    "${env:CMAKE_ARGS}" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_COMPILER="$gccPath" `
    -DCMAKE_CXX_COMPILER="$gxxPath" `
    -DCMAKE_PREFIX_PATH="${env:PREFIX}/lib" `
    -DCMAKE_INSTALL_PREFIX="${env:PREFIX}" `
    -DBUILD_SHARED_LIBS=ON `
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON `
    -G Ninja

  cmake --build . --target dydx_v4_proto -- -j"$env:CPU_COUNT"
  cmake --install . --component protocol

  # Rename dll.a into .lib
  Get-ChildItem -Path "${env:PREFIX}/lib" -Filter *.dll.a | ForEach-Object {
      $newName = $_.FullName -replace '\.dll\.a$', '.lib'
      Move-Item -Path $_.FullName -Destination $newName
  }
Pop-Location
