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

$dotnet_version = dotnet --version

$framework_version = $dotnet_version -replace "^(\d+\.\d+).*", '$1'
@"
<Project>
  <PropertyGroup>
    <TargetFrameworks>net$framework_version-windows</TargetFrameworks>
  </PropertyGroup>
</Project>
"@ | Set-Content "$SRC_DIR\Directory.Build.targets"

Get-ChildItem -Path . -Directory -Filter "obj" -Recurse | Remove-Item -Force -Recurse
Get-ChildItem -Path . -Directory -Filter "bin" -Recurse | Remove-Item -Force -Recurse
Remove-Item -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/translate*.cproj" -Force

(Get-Content $SRC_DIR/src/Infrastructure/src/UI/UI_NET.csproj) -replace "(<\/PropertyGroup>)", "    <UseWPF>true</UseWPF>`n`$1" | Set-Content $SRC_DIR/src/Infrastructure/src/UI/UI_NET.csproj
if ($env:PKG_VERSION -eq "1.15.3") {
    (Get-Content $SRC_DIR/Renode_NET.sln) | ForEach-Object {
        $_ -replace '(ReleaseHeadless\|Any CPU\.(ActiveCfg|Build\.0) = )Debug', '$1Release'
    } | Set-Content "$SRC_DIR/Renode_NET.sln"
    (Get-Content $SRC_DIR/src/Infrastructure/src/Emulator/Peripherals/Peripherals/Sensors/PAC1934.cs) -replace "GetBytes\(registers.Read\(offset\)\);", "GetBytes((ushort)registers.Read(offset));" | Set-Content "$SRC_DIR/src/Infrastructure/src/Emulator/Peripherals/Peripherals/Sensors/PAC1934.cs"
    (Get-Content $SRC_DIR/lib/termsharp/TermSharp_NET.csproj) -replace '"System.Drawing.Common" Version="5.0.2"', '"System.Drawing.Common" Version="5.0.3"' | Set-Content "$SRC_DIR/lib/termsharp/TermSharp_NET.csproj"
    (Get-Content $SRC_DIR/lib/termsharp/xwt/Xwt.Gtk/Xwt.Gtk3_NET.csproj) -replace '"System.Drawing.Common" Version="5.0.2"', '"System.Drawing.Common" Version="5.0.3"' | Set-Content "$SRC_DIR/lib/termsharp/xwt/Xwt.Gtk/Xwt.Gtk3_NET.csproj"
} else {
    Write-Host "Remove these patches from the script after 1.15.3"
    exit 1
}

# Renode computes its version based upon `git rev-parse --short=8 HEAD`
(Get-Content $SRC_DIR/tools/building/createAssemblyInfo.ps1) -replace 'git rev-parse --short=8 HEAD', '"0"' | Set-Content "$SRC_DIR/tools/building/createAssemblyInfo.ps1"

# Prepare, build, and install
New-Item -ItemType Directory -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/bin/Release/lib", "$SRC_DIR/output/bin/Release/net$framework_version", "$PREFIX/Library/bin", "$PREFIX/Library/libexec/$PKG_NAME", "$PREFIX/Library/share/$PKG_NAME/{scripts,platforms,tools/sel4_extensions}", "$SRC_DIR/license-files" -Force | Out-Null
Copy-Item -Path "$PREFIX/Library/bin/renode-cores/*" -Destination "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/bin/Release/lib" -Force
Copy-Item -Path "$SRC_DIR/src/Infrastructure/src/Emulator/Cores/windows-properties_NET.csproj" -Destination "$SRC_DIR/output/properties.csproj" -Force

$OUT_BIN_DIR = "$SRC_DIR\output\bin\Release"
"dotnet" | Out-File -FilePath "$SRC_DIR/output/bin/Release/build_type" -Encoding ascii
dotnet build -p:GUI_DISABLED=true -p:Configuration=ReleaseHeadless -p:GenerateFullPaths=true -p:Platform="Any CPU" "$SRC_DIR/Renode_NET.sln"

Copy-Item "$SRC_DIR/lib/resources/llvm/libllvm-disas.dll" "$SRC_DIR/output/bin/Release/" -Force

Copy-Item -Path "$SRC_DIR/output/bin/Release/net$framework_version-windows" -Destination "$PREFIX/Library/libexec/$PKG_NAME/" -Recurse -Force
Copy-Item -Path "$SRC_DIR/scripts" -Destination "$PREFIX/Library/share/$PKG_NAME/scripts" -Recurse -Force
Copy-Item -Path "$SRC_DIR/platforms" -Destination "$PREFIX/Library/share/$PKG_NAME/platforms" -Recurse -Force
Copy-Item -Path "$SRC_DIR/tools/sel4_extensions" -Destination "$PREFIX/Library/share/$PKG_NAME/tools/sel4_extensions" -Recurse -Force

dotnet-project-licenses --input "$SRC_DIR/src/Renode/Renode_NET.csproj" -d "$SRC_DIR/license-files" -f "txt"

# Create renode.cmd
New-Item -ItemType File -Path "$PREFIX\Library\bin\renode.cmd" -Force
@"
@echo off
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\Library\libexec\renode-cli\net$framework_version-windows\Renode.dll %*
"@ | Out-File -FilePath "$PREFIX\Library\bin\renode.cmd" -Encoding ascii

# Install tests for post-install testing
$TEST_PREFIX = "$SRC_DIR/test-bundle"

mkdir -p "$TEST_PREFIX/Library/bin"
mkdir -p "$TEST_PREFIX/Library/share/$PKG_NAME/tests"
Copy-Item -Path "tests/*" -Destination "$TEST_PREFIX/Library/share/$PKG_NAME/tests" -Recurse -Force
Copy-Item -Path "lib/resources/styles/robot.css" -Destination "$TEST_PREFIX/Library/share/$PKG_NAME/tests" -Force

# Use PowerShell's -replace operator
(Get-Content "$TEST_PREFIX/Library/share/$PKG_NAME/tests/robot_tests_provider.py") | ForEach-Object { $_ -replace "os\.path\.join\(this_path, '\.\./lib/resources/styles/robot\.css'\)", "os.path.join(this_path,'robot.css')" } | Set-Content "$TEST_PREFIX/Library/share/$PKG_NAME/tests/robot_tests_provider.py"

# Create renode-test script (using PowerShell heredoc)
@"
@echo off
setlocal enabledelayedexpansion
set "STTY_CONFIG=%stty -g 2^>nul%"
IF NOT DEFINED LOCAL_TEST_PREFIX (
  set "LOCAL_TEST_PREFIX=%CONDA_PREFIX%"
)
python "%LOCAL_TEST_PREFIX%\Library\share\renode-cli\tests\run_tests.py" --robot-framework-remote-server-full-directory "%CONDA_PREFIX%\Library\libexec\renode-cli" %*
set "RESULT_CODE=%ERRORLEVEL%"
if not "%STTY_CONFIG%"=="" stty "%STTY_CONFIG%"
exit /b %RESULT_CODE%
"@ | Out-File -FilePath "$TEST_PREFIX\Library\bin\renode-test.cmd" -Encoding ascii

# Terminate the dotnet processes that may hang around and prevent the build environment from being removed
try {
    Get-Process -Name *dotnet* | Stop-Process
}
catch {
    Write-Warning "Error removing the build environment: $_"
}

exit 0
