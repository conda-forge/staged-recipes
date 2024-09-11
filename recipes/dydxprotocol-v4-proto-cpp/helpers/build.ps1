$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"
$env:PATH = "${env:PREFIX}/Library/bin;$env:PATH"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-protocol, _conda-logs

Push-Location _conda-build-protocol

  $gccPath = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *-gcc.exe | Select-Object -First 1
  $gxxPath = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *-g++.exe | Select-Object -First 1

  $protobufDLL = Get-ChildItem -Path $env:PREFIX -Recurse -Filter *rotobuf.* | Select-Object -First 5 | Select-Object -ExpandProperty FullName
  $protobufLib = Get-ChildItem -Path $env:PREFIX -Recurse -Filter *rotobuf.* | Select-Object -First 5 | Select-Object -ExpandProperty FullName
  Write-Output "Protobuf DLLs in PREFIX: $protobufDLL"
  Write-Output "Protobuf Libraries in PREFIX: $protobufLib"

  $protobufDLL = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *rotobuf.* | Select-Object -First 5 | Select-Object -ExpandProperty FullName
  $protobufLib = Get-ChildItem -Path $env:BUILD_PREFIX -Recurse -Filter *rotobuf.* | Select-Object -First 5
  Write-Output "Protobuf DLLs in BUILD_PREFIX: $protobufDLL"
  Write-Output "Protobuf Libraries in BUILD_PREFIX: $protobufLib"

  Write-Output "g++ found at: $gxxPath"
  Write-Output "gcc found at: $gccPath"

  $_PREFIX = $env:PREFIX -replace '\\', '/'

  cmake "$env:SRC_DIR/v4-client-cpp" `
    "${env:CMAKE_ARGS}" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="$_PREFIX/lib;$_PREFIX/Library/lib;$_PREFIX/Library/bin" `
    -DCMAKE_INSTALL_PREFIX="$_PREFIX" `
    -DBUILD_SHARED_LIBS=ON `
    -DCMAKE_VERBOSE_MAKEFILE=ON `
    -G Ninja
    # -DCMAKE_CXX_COMPILER="$gxxPath" `
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target dydx_v4_proto_obj -- -j"$env:CPU_COUNT"
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target dydx_v4_proto -- -j"$env:CPU_COUNT"
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --install . --component protocol
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  # Rename dll.a into .lib
  Get-ChildItem -Path "${env:PREFIX}/lib" -Filter *.dll.a | ForEach-Object {
      $newName = $_.FullName -replace '\.dll\.a$', '.lib'
      Move-Item -Path $_.FullName -Destination $newName
  }
Pop-Location
