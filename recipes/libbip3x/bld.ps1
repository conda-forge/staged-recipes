# Define paths
$build_dir = Join-Path $env:SRC_DIR "build-release"
$pre_install_dir = Join-Path $env:SRC_DIR "pre-install"
$test_release_dir = Join-Path $env:SRC_DIR "test-release"

# Update PATH
$env:PATH = "$env:PREFIX\bin;" + $env:PATH

# Build and install
New-Item -Path $build_dir -ItemType Directory -Force
New-Item -Path $pre_install_dir -ItemType Directory -Force

Set-Location $build_dir
    cmake $env:CMAKE_ARGS `
      -G "Ninja" `
      -D CMAKE_BUILD_TYPE=Release `
      -D CMAKE_INSTALL_PREFIX="$pre_install_dir" `
      -D CMAKE_VERBOSE_MAKEFILE=ON `
      -D bip3x_BUILD_SHARED_LIBS=ON `
      -D bip3x_BUILD_JNI_BINDINGS=ON `
      -D bip3x_BUILD_C_BINDINGS=ON `
      -D bip3x_USE_OPENSSL_RANDOM=ON `
      -D bip3x_BUILD_TESTS=ON `
      $env:SRC_DIR
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cmake --build . --config Release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cmake --install . --config Release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Set-Location $env:SRC_DIR

# Remove 'toolbox' files
Get-ChildItem -Path $pre_install_dir -Recurse -Filter '*toolbox*' | Remove-Item -Force -Recurse

# Prepare test area
New-Item -Path $test_release_dir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $build_dir 'bin') -Destination $test_release_dir -Recurse
Get-ChildItem -Path $pre_install_dir -Recurse | Where-Object { $_.FullName -match 'GTest' -or $_.FullName -match 'gtest' } | ForEach-Object { Copy-Item -Path $_.FullName -Destination $test_release_dir -Recurse -Force }
Get-ChildItem -Path $pre_install_dir -Recurse | Where-Object { $_.FullName -match 'GTest' -or $_.FullName -match 'gtest' } | Remove-Item -Force -Recurse

# Test binary is not installed on windows, apparently
Get-ChildItem -Path (Join-Path $build_dir 'bip3x-test.exe') -Recurse | Where-Object { $_ -ne $null } | ForEach-Object { Copy-Item -Path $_.FullName -Destination (Join-Path $test_release_dir 'bin') -Recurse }

# CMake was patched to create versioned windows DLLs, but the side-effect is that it creates bip3x.3.lib as well
# Converting bip3x.3.lib to bip3x.lib. It will still refer to bip3x.3.dll, but that should be fine.
Get-ChildItem -Path pre_install_dir -Recurse -Include 'bip3x.3.lib', 'cbip3x.3.lib', 'bip3x_jni.3.lib' | Rename-Item -NewName { $_.Name -replace '.3.lib', '.lib' }

# Transfer pre-install to PREFIX
Set-Location $pre_install_dir
    Copy-Item -Path '.\*' -Destination $ENV:PREFIX -Recurse -Force -PassThru | Select-Object -ExpandProperty FullName
Set-Location $env:SRC_DIR

# Clean up
Remove-Item -Path $build_dir -Recurse -Force
Remove-Item -Path $pre_install_dir -Recurse -Force
