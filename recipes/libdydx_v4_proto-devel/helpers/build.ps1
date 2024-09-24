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
    -DCMAKE_VERBOSE_MAKEFILE=ON `
    -DBUILD_SHARED_LIBS=ON `
    -G Ninja --debug-output
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

  dlltool --export-all-symbols --output-def $DEF --input-def $DLL.FullName

  if ($env:target_platform -eq "win-64") {
      dlltool --def $DEF --output-lib $LIB --dllname $DLL.FullName --machine x64
  } else {
      dlltool --def $DEF --output-lib $LIB --dllname $DLL.FullName --machine aarch64
  }

  $libSymbols = dumpbin /linkermember:1 $LIB | Select-String -Pattern "cosmos::base::v1beta1"
  if (-not $libSymbols) {
    Write-Output "Symbol 'cosmos::base::v1beta1' not found in $($LIB)"
    # Display the content of the .def file
    Get-Content $DEF
    exit 1
  }

  Remove-Item $DEF
} else {
  Write-Output "DLL file not found."
  exit 1
}

# Install .lib in the library
Copy-Item -Path $LIB -Destination "$env:PREFIX/Library/lib"
