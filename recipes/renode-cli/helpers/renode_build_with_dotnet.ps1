$ErrorActionPreference = "Stop"

# Get logical processors count
$cpuCount = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors

# Set environment variables (using robust expansion)
$SRC_DIR = & cmd.exe /c echo %SRC_DIR%
$PREFIX = & cmd.exe /c echo %PREFIX%
$PKG_NAME = & cmd.exe /c echo %PKG_NAME%

# Check for empty environment variables
if ([string]::IsNullOrEmpty($SRC_DIR)) { throw "SRC_DIR is empty" }
if ([string]::IsNullOrEmpty($PREFIX)) { throw "PREFIX is empty" }
if ([string]::IsNullOrEmpty($PKG_NAME)) { throw "PKG_NAME is empty" }

# Set environment variables
$env:PATH = "${env:BUILD_PREFIX}/Library/mingw-w64/bin;${env:BUILD_PREFIX}/Library/bin;${env:PREFIX}/Library/bin;${env:PREFIX}/bin;${env:PATH}"

# Function to install tests (defined before use in PowerShell)
function install_tests {
    param(
        [string]$test_prefix,
        [string]$pkg_name,
        [string]$conda_prefix
    )

    mkdir -p "$test_prefix/bin"
    mkdir -p "$test_prefix/share/$pkg_name/tests"
    Copy-Item -Path "tests/*" -Destination "$test_prefix/share/$pkg_name/tests" -Recurse -Force
    Copy-Item -Path "lib/resources/styles/robot.css" -Destination "$test_prefix/share/$pkg_name/tests" -Force

    # Use PowerShell's -replace operator
    (Get-Content "$test_prefix/share/$pkg_name/tests/robot_tests_provider.py") | ForEach-Object { $_ -replace "os\.path\.join\(this_path, '\.\./lib/resources/styles/robot\.css'\)", "os.path.join(this_path,'robot.css')" } | Set-Content "$test_prefix/share/$pkg_name/tests/robot_tests_provider.py"

    # Create renode-test script (using PowerShell heredoc)
    @"
@echo off
setlocal enabledelayedexpansion
set "STTY_CONFIG=%stty -g 2^>nul%"
IF NOT DEFINED LOCAL_TEST_PREFIX (
  set "LOCAL_TEST_PREFIX=%CONDA_PREFIX%"
)
python3 "%LOCAL_TEST_PREFIX%\opt\renode-cli\tests\run_tests.py" --robot-framework-remote-server-full-directory "%CONDA_PREFIX%\libexec\renode-cli" %*
set "RESULT_CODE=%ERRORLEVEL%"
if not "%STTY_CONFIG%"=="" stty "%STTY_CONFIG%"
exit /b %RESULT_CODE%
"@ | Out-File -FilePath "$PREFIX\bin\renode-test.cmd" -Encoding ascii

    # No need for chmod +x in PowerShell, but ensure execution policy allows it
}

# Consolidated script logic
$dotnet_version = dotnet --version
$framework_version = $dotnet_version -replace "^(\d+\.\d+).*", '$1'

# Patch project files, remove obj/bin, fix sln (combined commands)
Get-ChildItem -Path lib,src,tests -Filter "*.csproj" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) | ForEach-Object { $_ -replace "([>;])net6\.0([<;])", "`$1net$framework_version`$2" } | Set-Content $_.FullName
}
Get-ChildItem -Path . -Directory -Filter "obj","bin" -Recurse | Remove-Item -Force -Recurse
(Get-Content Renode_NET.sln) | ForEach-Object { $_ -replace "(ReleaseHeadless\|Any .+ = )Debug", '$1Release' } | Set-Content Renode_NET.sln

# Prepare, build, and install (combined and simplified)
New-Item -ItemType Directory -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/bin/Release/lib", "$SRC_DIR/output/bin/Release/net$framework_version", "$PREFIX/bin", "$PREFIX/libexec/$PKG_NAME", "$PREFIX/share/$PKG_NAME/{scripts,platforms,tests}", "license-files" -Force | Out-Null

# Symbolic links are tricky in Windows, use Copy-Item instead
Copy-Item -Path "$PREFIX/lib/renode-cores/*" -Destination "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/bin/Release/lib" -Force

Remove-Item -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/translate*.cproj" -Force

Copy-Item -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/${target_platform%%-*}-properties.csproj" -Destination "$SRC_DIR/output/properties.csproj" -Force

dotnet build -p:GUI_DISABLED=true -p:Configuration=ReleaseHeadless -p:GenerateFullPaths=true -p:Platform="Any CPU" "$SRC_DIR/Renode_NET.sln"
"dotnet" | Out-File -FilePath "$SRC_DIR/output/bin/Release/build_type" -Encoding ascii

Copy-Item "lib/resources/llvm/libllvm-disas$([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture).ToString().Replace('X64','amd64').Replace('X86','i386')$SHLIB_EXT" "$SRC_DIR/output/bin/Release/libllvm-disas$([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture).ToString().Replace('X64','amd64').Replace('X86','i386')$SHLIB_EXT" -Force

Copy-Item -Path "$SRC_DIR/output/bin/Release/net$framework_version/*" -Destination "$PREFIX/libexec/$PKG_NAME/" -Recurse -Force
Copy-Item -Path "$SRC_DIR/scripts/*" -Destination "$PREFIX/share/$PKG_NAME/scripts" -Recurse -Force
Copy-Item -Path "$SRC_DIR/platforms/*" -Destination "$PREFIX/share/$PKG_NAME/platforms" -Recurse -Force

$licensesPath = Resolve-Path "license-files"
& bash.exe -c "
  SRC_DIR=$(cygpath -u '$Env:SRC_DIR') # Convert SRC_DIR to Unix path
  scriptPath=$(cygpath -u '$SRC_DIR/tools/packaging/common_copy_licenses.sh')
  licensesPath=$(cygpath -u '$licensesPath')
  \"$scriptPath\" \"$licensesPath\" windows
"

# Create renode.cmd
New-Item -ItemType File -Path "$PREFIX\bin\renode.cmd" -Force
@"
@echo off
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\renode-cli\Renode.dll %*
"@ | Out-File -FilePath "$PREFIX\bin\renode.cmd" -Encoding ascii

# Install tests
install_tests "$SRC_DIR/test-bundle" "$PKG_NAME" "$PREFIX"

exit 0
