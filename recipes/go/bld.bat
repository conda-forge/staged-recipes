setlocal enabledelayedexpansion

rem First, build go1.4 using gcc, then use that go to build go>1.4
mkdir go-bootstrap
cd go-bootstrap

set BOOTSTRAP_TARBALL=go1.4-bootstrap-20170531.tar.gz
rem https://storage.googleapis.com/golang/go1.4-bootstrap-20170531.tar.gz.sha256
set BOOTSTRAP_TARBALL_CHECKSUM=49f806f66762077861b7de7081f586995940772d29d4c45068c134441a743fa2
rem ALPN doesn't work for Windows < 8.1 https://github.com/curl/curl/issues/840
curl --no-alpn -LO "https://storage.googleapis.com/golang/%BOOTSTRAP_TARBALL%"
if errorlevel 1 exit 1

set /a count=1
for /f "skip=1 delims=:" %%a in ('CertUtil -hashfile %BOOTSTRAP_TARBALL% SHA256') do (
  if !count! equ 1 set "sha256=%%a"
  set /a count+=1
)
set "sha256=%sha256: =%
if NOT "%sha256%" == "%BOOTSTRAP_TARBALL_CHECKSUM%" exit 1

tar -xzf %BOOTSTRAP_TARBALL%
if errorlevel 1 exit 1

del %BOOTSTRAP_TARBALL%
if errorlevel 1 exit 1

set GOROOT_BOOTSTRAP=%cd%\go
cd %GOROOT_BOOTSTRAP%\src
call make.bat
if errorlevel 1 exit 1

cd %SRC_DIR%\src
call all.bat
if errorlevel 1 exit 1

rmdir /s /q %GOROOT_BOOTSTRAP%
mkdir %PREFIX%\go
xcopy /s /y /i /q %SRC_DIR%\* %PREFIX%\go\
del %PREFIX%\go\bld.bat

for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f %LIBRARY_BIN%
)

rem all files in bin are gone, go finds its *.go files via the GOROOT variable
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1

rem Install [de]activate scripts.
rem Copy the [de]activate scripts to %LIBRARY_PREFIX%\etc\conda\[de]activate.d.
rem This will allow them to be run on environment activation.
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1
  copy "%RECIPE_DIR%\%%F.bat" "%PREFIX%\etc\conda\%%F.d\go_%%F.bat"
  if errorlevel 1 exit 1
)
