@echo off
setlocal enabledelayedexpansion

:: Enable CGO for SQLite support
set CGO_ENABLED=1

:: Set Go build flags
set GOFLAGS=-buildmode=pie -trimpath -mod=readonly -modcacherw

:: Version from conda build (or rattler-build)
set VERSION=%PKG_VERSION%

:: Remember source directory (handle both conda-build and rattler-build)
if defined SRC_DIR (
    set SRC_ROOT=%SRC_DIR%
) else (
    set SRC_ROOT=%cd%
)

:: Debug info
echo === Build environment ===
echo SRC_ROOT: %SRC_ROOT%
echo PREFIX: %PREFIX%
echo LIBRARY_BIN: %LIBRARY_BIN%
echo LIBRARY_PREFIX: %LIBRARY_PREFIX%
echo PWD: %cd%

:: Collect licenses from Go dependencies
:: Remove existing directory first to avoid "already exists" error
echo === Collecting dependency licenses with go-licenses ===
if exist "%SRC_ROOT%\library_licenses" rmdir /S /Q "%SRC_ROOT%\library_licenses"
mkdir "%SRC_ROOT%\library_licenses"

go-licenses save ./... --save_path="%SRC_ROOT%\library_licenses" --ignore=github.com/writefreely/writefreely
if errorlevel 1 (
    echo WARNING: go-licenses had some issues, but continuing...
)

echo Collected licenses:
dir "%SRC_ROOT%\library_licenses" 2>nul

:: Build the writefreely binary with SQLite and netgo support
echo === Building WriteFreely ===
cd "%SRC_ROOT%\cmd\writefreely"
if errorlevel 1 exit /b 1

go build -v -tags="netgo sqlite" -ldflags="-s -w -X 'github.com/writefreely/writefreely.softwareVer=%VERSION%'" -o "%LIBRARY_BIN%\writefreely.exe" .
if errorlevel 1 exit /b 1

:: Return to source root (IMPORTANT for license file detection)
cd "%SRC_ROOT%"

:: Copy static assets and templates
echo === Copying static assets ===
mkdir "%LIBRARY_PREFIX%\share\writefreely" 2>nul
xcopy /E /I /Y pages "%LIBRARY_PREFIX%\share\writefreely\pages" 2>nul
xcopy /E /I /Y templates "%LIBRARY_PREFIX%\share\writefreely\templates" 2>nul
xcopy /E /I /Y static "%LIBRARY_PREFIX%\share\writefreely\static" 2>nul
xcopy /E /I /Y keys "%LIBRARY_PREFIX%\share\writefreely\keys" 2>nul
copy /Y schema.sql "%LIBRARY_PREFIX%\share\writefreely\" 2>nul
copy /Y sqlite.sql "%LIBRARY_PREFIX%\share\writefreely\" 2>nul

echo === Build completed successfully! ===
echo Final directory: %cd%
