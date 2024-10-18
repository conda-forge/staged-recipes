$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig"
$env:PATH = "${env:PREFIX}/Library/bin;$env:PATH"

$PROJECT = "dydx_v4_proto"

Copy-Item -Recurse all-sources/v4-client-cpp $env:SRC_DIR

New-Item -ItemType Directory -Force -Path _conda-build-protocol, _conda-logs

Push-Location _conda-build-protocol

  $_PREFIX = $env:PREFIX -replace '\\', '/'

  cmake "$env:SRC_DIR/v4-client-cpp" `
    "${env:CMAKE_ARGS}" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="$_PREFIX/lib;$_PREFIX/Library/lib" `
    -DCMAKE_INSTALL_PREFIX="$_PREFIX/Library" `
    -DCMAKE_VERBOSE_MAKEFILE=ON `
    -DBUILD_SHARED_LIBS=ON `
    -G Ninja
  if ($LASTEXITCODE -ne 0) {
    Write-Output "CMake failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }

  cmake --build . --target $PROJECT -- -j"$env:CPU_COUNT"
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
$DLL = Get-ChildItem -Path "$env:PREFIX" -Filter "*.dll" -Recurse | Where-Object { $_.Name -match $PROJECT }
$LIB = Get-ChildItem -Path "$env:PREFIX" -Filter "*.lib" -Recurse | Where-Object { $_.Name -match $PROJECT }
# Check for Coin::mutable_denom in LIB
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

if ($LIB) {
  Write-Output "Valid .lib found: $LIB"
} else {
  $LIB = $PROJECT + ".lib"
  $DEF = $PROJECT + ".def"

  $dumpOutput = & dumpbin /exports $DLL.FullName

  $exports = $dumpOutput |
      Select-String -Pattern '(?:\s*\d+\s+[\dA-F]+\s+[\dA-F]+\s+)?(\?+[\w@]+)' |
      ForEach-Object { $_.Matches.Groups[1].Value } |
      Where-Object { $_ -ne '' }

  "EXPORTS" | Set-Content $DEF
  $exports | ForEach-Object { "    $_" } | Add-Content $DEF

  if ($env:target_platform -eq "win-64") {
      $libResult = lib /def:$DEF /out:$LIB /machine:x64
  } else {
      $libResult = lib /def:$DEF /out:$LIB /machine:aarch64
  }
  if ($LASTEXITCODE -ne 0) {
      Write-Output "Failed to create .lib file: $libResult"
      exit 1
  }

  # Check for Coin::mutable_denom in LIB
  $coinMutableDenom = dumpbin /linkermember:1 $LIB | Select-String -Pattern "\?mutable_denom@Coin"
  if (-not $coinMutableDenom) {
      Write-Output "Coin::mutable_denom not found in $LIB"
      exit 1
  } else {
      Write-Output "Found Coin::mutable_denom in $LIB"
      $coinMutableDenom | ForEach-Object { Write-Output $_.Line }
  }

  Copy-Item -Path $LIB -Destination "$env:PREFIX/Library/lib" -Force
}
