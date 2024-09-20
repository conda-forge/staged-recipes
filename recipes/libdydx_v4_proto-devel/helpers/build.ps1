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
    -G Ninja
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
Pop-Location

# Create .lib file for Windows
$DLL = Get-ChildItem -Path "$env:PREFIX" -Filter "*.dll" -Recurse | Where-Object { $_.Name -match "dydx_v4_proto" }
if ($DLL) {
  $DEF = $DLL.BaseName -replace ".dll", ".def"
  $LIB = $DLL.FullName -replace "-\d+.dll", ".lib"
  $LIB = $LIB -replace "Library\\bin", "Library\\lib"

  # Check if the symbol exists in the .dll
  $dllExports = dumpbin /exports $DLL.FullName | Select-String -Pattern "cosmos::base::v1beta1"
  if (-not $dllExports) {
    Write-Output "Symbol 'cosmos::base::v1beta1' not found in $($DLL.FullName)"
    exit 1
  }

  dumpbin /exports $DLL.FullName | Select-String -Pattern "^[0-9A-F]+\s+[0-9A-F]+\s+.*$" | ForEach-Object { $_.ToString().Split(" ")[3] } | Out-File -FilePath $DEF

  if ($env:target_platform -eq "win-64") {
      lib /def:$DEF /out:$LIB /machine:x64
  } else {
      lib /def:$DEF /out:$LIB /machine:aarch64
  }

  # Check if the symbol exists in the .lib
  $libSymbols = dumpbin /linkermember:1 $LIB | Select-String -Pattern "cosmos::base::v1beta1"
  if (-not $libSymbols) {
    Write-Output "Symbol 'cosmos::base::v1beta1' not found in $($LIB)"
    exit 1
  }

  Remove-Item $DEF
} else {
  Write-Output "DLL file not found."
  exit 1
}