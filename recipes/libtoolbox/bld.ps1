# Define paths
$build_dir = Join-Path $env:SRC_DIR "build-release"
$test_release_dir = Join-Path $env:SRC_DIR "test-release"

# Update PATH
$env:PATH = "$env:PREFIX\bin;" + $env:PATH

# Build and install
New-Item -Path $build_dir -ItemType Directory -Force

Set-Location $build_dir
    cmake $env:CMAKE_ARGS `
      -G "Ninja" `
      -D CMAKE_BUILD_TYPE=Release `
      -D CMAKE_VERBOSE_MAKEFILE=ON `
      -D CMAKE_INSTALL_PREFIX="$env:PREFIX" `
      -D toolbox_BUILD_SHARED_LIBS=ON `
      -D toolbox_BUILD_TESTS=ON `
      $env:SRC_DIR
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cmake --build . --config Release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cmake --build . --target toolbox-test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cmake --install . --config Release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Set-Location $env:SRC_DIR

# Prepare test area
New-Item -Path $test_release_dir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $build_dir 'bin') -Destination $test_release_dir -Recurse
Get-ChildItem -Path $env:PREFIX -Recurse | Where-Object { $_.FullName -match 'GTest' -or $_.FullName -match 'gtest' } | ForEach-Object { Copy-Item -Path $_.FullName -Destination $test_release_dir -Recurse -Force }
Get-ChildItem -Path $env:PREFIX -Recurse | Where-Object { $_.FullName -match 'GTest' -or $_.FullName -match 'gtest' } | Remove-Item -Force -Recurse

# Test binary is not installed on windows, apparently
Get-ChildItem -Path (Join-Path $build_dir 'toolbox-test.exe') -Recurse | Where-Object { $_ -ne $null } | ForEach-Object { Copy-Item -Path $_.FullName -Destination (Join-Path $test_release_dir 'bin') -Recurse }

# CMake was patched to create versioned windows DLLs, but the side-effect is that it creates toolbox.3.lib as well
# Converting toolbox.3.lib to toolbox.lib. It will still refer to toolbox.3.dll, but that should be fine.
Get-ChildItem -Path $env:PREFIX -Recurse -Filter "*.lib" | Where-Object { $_.Name -match "\.\d+\.lib$" } | Rename-Item -NewName { $_.Name -replace "\.\d+(\.lib)$", '$1' }

# Clean up
Remove-Item -Path $build_dir -Recurse -Force
