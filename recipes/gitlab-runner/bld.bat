
set "PKG=gitlab.com\\gitlab-org\\%PKG_NAME%"
for /F "tokens=1,2 delims=." %%i in ("%PKG_VERSION%") do set "MAJOR=%%i" &set "MINOR=%%j"
set "BRANCH=%MAJOR%-%MINOR%-stable"
for /F "delims=" %%i in ('date.exe +%Y-%m-%dT%H:%M:%S%:z') DO set BUILD=%%i
set "GOPATH=%SRC_DIR%"

go build -ldflags ^
	"-X %PKG%/common.NAME=%PKG_NAME% ^
	-X %PKG%/common.VERSION=%PKG_VERSION% ^
	-X %PKG%/common.REVISION=%REVISION% ^
	-X %PKG%/common.BRANCH=%BRANCH% ^
	-X %PKG%/common.BUILT=%BUILT%" ^
	%PKG%
if errorlevel 1 exit 1

install gitlab-runner "%LIBRARY_BIN%"
if errorlevel 1 exit 1
