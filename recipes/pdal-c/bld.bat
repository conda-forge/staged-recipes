
if not defined BUILD_TYPE set BUILD_TYPE=Release
set ARCH=x64
if not defined TARGET_OS set TARGET_OS=windows

set TRIPLET=%ARCH%-%TARGET_OS%

set BUILD_DIR=%SCRIPT_DIR%\build\%TRIPLET%

if exist "%BUILD_DIR%\pdal-c.sln" (
	pushd "%BUILD_DIR%"
) else (
	mkdir "%BUILD_DIR%"
	pushd "%BUILD_DIR%"

	cmake ../.. ^
		-G "Visual Studio 15 2017"  ^
		-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
		-DCONDA_BUILD=ON

)

:: Build and install solution
cmake --build . --target INSTALL --config %BUILD_TYPE%
