# Set framework version
$dotnet_version = (dotnet --version)
if ($dotnet_version -match "^(\d+\.\d+)") {
    $framework_version = $Matches[1]
} else {
    Write-Error "Could not determine .NET version.  Using default 8.0."
    $framework_version = "8.0"
}

$SRC_DIR = Resolve-Path "$Env:SRC_DIR"
$BUILD_PREFIX = Resolve-Path "$Env:BUILD_PREFIX"
$PREFIX = Resolve-Path "$Env:PREFIX"
$PKG_NAME = $Env:PKG_NAME

# Update Renode_NET.sln (replace Debug with Release)
(Get-Content "Renode_NET.sln") | ForEach-Object { $_ -replace "(ReleaseHeadless\|Any CPU\..+ = )Debug", '$1Release' } | Set-Content "Renode_NET.sln"

$csprojFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.csproj" -Recurse
foreach ($file in $csprojFiles) {
    $csprojContent = (Get-Content $file.FullName)

    # Update System.Drawing.Common to 5.0.3
    $csprojContent = $csprojContent -replace "<PackageReference Include=`"System\.Drawing\.Common`" Version=`"5\..*`" />", "<PackageReference Include=`"System.Drawing.Common`" Version=`"5.0.3`" />"

    # Add package reference only to UI_NET.csproj
    if ($file.FullName -match "(UI)_NET\.csproj") {
        if ($csprojContent -notmatch "PresentationFramework") {
            # $csprojContent = $csprojContent -replace "(<\/Project>)", "  <ItemGroup>`n    <PackageReference Include=`"PresentationFramework`" Version=`"4.6.0`" />`n  </ItemGroup>`n`$1"
            $csprojContent = $csprojContent -replace "(<\/PropertyGroup>)", "     <UseWPF>true</UseWPF>`n`$1"
        }
    }

    # Remove excessive warnings .csproj files (TargetFramework and NoWarn)
    $csprojContent = $csprojContent -replace "(<PropertyGroup>)", "`$1`n`t`t<NoWarn>CA1416;CS0649;CS0168;CS0219;CS8981;SYSLIB0050;SYSLIB0051</NoWarn>"
    Set-Content -Path $file.FullName -Value $csprojContent
}

# Install renode-cores .so where they are looked for
New-Item -ItemType Directory -Path "$SRC_DIR\src\Infrastructure\src\Emulator\Cores\bin\Release\lib" -Force
Copy-Item -Path "$BUILD_PREFIX\Library\lib\renode-cores\*" -Destination "$SRC_DIR\src\Infrastructure\src\Emulator\Cores\bin\Release\lib" -Force

# Remove C cores not built in this recipe
Remove-Item -Path "$SRC_DIR\src\Infrastructure\src\Emulator\Cores\translate*.cproj" -Force

# Build with dotnet
New-Item -ItemType Directory -Path "$PREFIX\Library\lib" -Force
& $Env:RECIPE_DIR\helpers\renode_build_with_dotnet.ps1 $framework_version

# Install procedure
New-Item -ItemType Directory -Path "$PREFIX\libexec\$PKG_NAME" -Force
Copy-Item -Path "$SRC_DIR\output\bin\Release\net$framework_version-windows\*" -Destination "$PREFIX\libexec\$PKG_NAME\" -Recurse -Force

New-Item -ItemType Directory -Path "$PREFIX\opt\$PKG_NAME\scripts", "$PREFIX\opt\$PKG_NAME\platforms", "$PREFIX\opt\$PKG_NAME\tests", "$PREFIX\opt\$PKG_NAME\tools", "$PREFIX\opt\$PKG_NAME\licenses" -Force

Copy-Item -Path "$SRC_DIR\.renode-root" -Destination "$PREFIX\opt\$PKG_NAME" -Force
Copy-Item -Path "$SRC_DIR\scripts\*" -Destination "$PREFIX\opt\$PKG_NAME\scripts" -Recurse -Force
Copy-Item -Path "$SRC_DIR\platforms\*" -Destination "$PREFIX\opt\$PKG_NAME\platforms" -Recurse -Force
Copy-Item -Path "$SRC_DIR\tests\*" -Destination "$PREFIX\opt\$PKG_NAME\tests" -Recurse -Force
Copy-Item -Path "$SRC_DIR\tools\metrics_analyzer", "$SRC_DIR\tools\execution_tracer", "$SRC_DIR\tools\gdb_compare", "$SRC_DIR\tools\sel4_extensions" -Destination "$PREFIX\opt\$PKG_NAME\tools" -Recurse -Force

Copy-Item "$SRC_DIR\lib\resources\styles\robot.css" "$PREFIX\opt\$PKG_NAME\tests" -Force

$licensesPath = (Resolve-Path "$PREFIX\opt\$PKG_NAME\licenses").Path -replace '\\', '/'
$scriptPath = (Resolve-Path "$SRC_DIR\tools\packaging\common_copy_licenses.sh").Path -replace '\\', '/'
$command = "'$scriptPath' '$licensesPath' 'linux'"
& "bash.exe" -c $command
Copy-Item -Path "$PREFIX\opt\$PKG_NAME\licenses" -Destination "license-files" -Recurse -Force

# Update robot_tests_provider.py (replace path to robot.css)
(Get-Content "$PREFIX\opt\$PKG_NAME\tests\robot_tests_provider.py") | ForEach-Object { $_ -replace "os\.path\.join\(this_path, '\.\./lib/resources/styles/robot\.css'\)", "os.path.join(this_path,'robot.css')" } | Set-Content "$PREFIX\opt\$PKG_NAME\tests\robot_tests_provider.py"

# Create renode.cmd
New-Item -ItemType File -Path "$PREFIX\bin\renode.cmd" -Force
@"
@echo off
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\renode-cli\Renode.dll %*
"@ | Out-File -FilePath "$PREFIX\bin\renode.cmd" -Encoding ascii
# No chmod +x needed in PowerShell

# Create renode-test.cmd
New-Item -ItemType File -Path "$PREFIX\bin\renode-test.cmd" -Force
@"
@echo off
setlocal enabledelayedexpansion
set "STTY_CONFIG=%stty -g 2^>nul%"
python3 "%CONDA_PREFIX%\opt\renode-cli\tests\run_tests.py" --robot-framework-remote-server-full-directory "%CONDA_PREFIX%\libexec\renode-cli" %*
set "RESULT_CODE=%ERRORLEVEL%"
if not "%STTY_CONFIG%"=="" stty "%STTY_CONFIG%"
exit /b %RESULT_CODE%
"@ | Out-File -FilePath "$PREFIX\bin\renode-test.cmd" -Encoding ascii
