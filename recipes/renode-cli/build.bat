@echo off
setlocal enabledelayedexpansion

set "install_prefix=%PREFIX%\opt\%PKG_NAME%"

:: for /f "tokens=*" %%i in ('dotnet --version') do set "dotnet_version=%%i"
:: set "framework_version=%dotnet_version:~0,-2%"
set "framework_version=8.0"

rem Patch the project files to use the correct .NET version
:: for /f "delims=" %%i in ('find lib src tests -name "*.csproj"') do (
::     sed -i -E "s/([>;])net6.0([<;])/\1net${framework_version}\2/" "%%i"
::     sed -i -E "s|^((\s+)<PropertyGroup>)|\1\n\2\2<NoWarn>CS0168;CS0219;CS8981;SYSLIB0050;SYSLIB0051</NoWarn>|" "%%i"
:: )
:: %BUILD_PREFIX%\Library\usr\bin\find.exe lib src tests -name "*.csproj" -exec sed -i -E ^
::   -e "s/([>;])net6.0([<;])/\1net${framework_version}\2/" ^
::   -e "s|^((\s+)<PropertyGroup>)|\1\n\2\2<NoWarn>CS0168;CS0219;CS8981;SYSLIB0050;SYSLIB0051</NoWarn>|" ^
::   -e 's|^(\s+)<(Package)?Reference\s+Include="Mono.Posix".*\n||g' ^
::   {} \;
:: %BUILD_PREFIX%\Library\usr\bin\find.exe . -type d -name "obj" -exec rm -rf {} \;
:: %BUILD_PREFIX%\Library\usr\bin\find.exe . -type d -name "bin" -exec rm -rf {} \;
sed -i -E "s/(ReleaseHeadless\|Any .+ = )Debug/\1Release/" Renode_NET.sln

rem Prevent CMake build since we provide the binaries
mkdir "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\bin\Release\lib"
copy "%BUILD_PREFIX%\lib\renode-cores\*" "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\bin\Release\lib"

rem Remove the C cores that are not built in this recipe
del "%SRC_DIR%\src\Infrastructure\src\Emulator\Cores\translate*.cproj"

rem Build with dotnet
call powershell "%RECIPE_DIR%\helpers\renode_build_with_dotnet.ps1" %framework_version%

rem Install procedure
mkdir "%PREFIX%\libexec\%PKG_NAME%"
xcopy /e /i /y "output\bin\Release\net%framework_version%\*" "%PREFIX%\libexec\%PKG_NAME%"

mkdir "%PREFIX%\opt\%PKG_NAME%\scripts"
mkdir "%PREFIX%\opt\%PKG_NAME%\platforms"
mkdir "%PREFIX%\opt\%PKG_NAME%\tests"
mkdir "%PREFIX%\opt\%PKG_NAME%\tools"
mkdir "%PREFIX%\opt\%PKG_NAME%\licenses"

copy ".renode-root" "%PREFIX%\opt\%PKG_NAME%"
xcopy /e /i /y "scripts\*" "%PREFIX%\opt\%PKG_NAME%\scripts"
xcopy /e /i /y "platforms\*" "%PREFIX%\opt\%PKG_NAME%\platforms"
xcopy /e /i /y "tests\*" "%PREFIX%\opt\%PKG_NAME%\tests"
xcopy /e /i /y "tools\metrics_analyzer" "%PREFIX%\opt\%PKG_NAME%\tools"
xcopy /e /i /y "tools\execution_tracer" "%PREFIX%\opt\%PKG_NAME%\tools"
xcopy /e /i /y "tools\gdb_compare" "%PREFIX%\opt\%PKG_NAME%\tools"
xcopy /e /i /y "tools\sel4_extensions" "%PREFIX%\opt\%PKG_NAME%\tools"

copy "lib\resources\styles\robot.css" "%PREFIX%\opt\%PKG_NAME%\tests"

call tools\packaging\common_copy_licenses.bat "%PREFIX%\opt\%PKG_NAME%\licenses" linux
xcopy /e /i /y "%PREFIX%\opt\%PKG_NAME%\licenses" "license-files"

sed -i.bak "s#os\.path\.join(this_path, '\.\./lib/resources/styles/robot\.css')#os.path.join(this_path,'robot.css')#g" "%PREFIX%\opt\%PKG_NAME%\tests\robot_tests_provider.py"
del "%PREFIX%\opt\%PKG_NAME%\tests\robot_tests_provider.py.bak"

mkdir "%PREFIX%\bin"
(
echo @echo off
echo call %%DOTNET_ROOT%%\dotnet exec %%CONDA_PREFIX%%\libexec\renode-cli\Renode.dll %%*
) > "%PREFIX%\bin\renode.cmd"
chmod +x "%PREFIX%\bin\renode.cmd"

(
echo @echo off
echo setlocal enabledelayedexpansion
echo set "STTY_CONFIG=%%stty -g 2^>nul%%"
echo python3 "%%CONDA_PREFIX%%\opt\renode-cli\tests\run_tests.py" --robot-framework-remote-server-full-directory "%%CONDA_PREFIX%%\libexec\renode-cli" %%*
echo set "RESULT_CODE=%%ERRORLEVEL%%"
echo if not "%%STTY_CONFIG%%"=="" stty "%%STTY_CONFIG%%"
echo exit /b %%RESULT_CODE%%
) > "%PREFIX%\bin\renode-test.cmd"
chmod +x "%PREFIX%\bin\renode-test.cmd"
