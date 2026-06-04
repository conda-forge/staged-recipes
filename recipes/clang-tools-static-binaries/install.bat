@echo off
REM install.bat – conda-build install script for a single clang-tools version (Windows)
REM
REM Environment variables (set by meta.yaml):
REM   RELEASE_TAG    GitHub release tag (e.g. 2026.06.04-14db129d)
REM   CLANG_VERSION  Clang major version (e.g. 20)
REM   PREFIX         Conda install prefix

setlocal enabledelayedexpansion

set "RELEASE_URL=https://github.com/cpp-linter/clang-tools-static-binaries/releases/download/%RELEASE_TAG%"
set "TOOLS=clang-format clang-tidy clang-query clang-apply-replacements"

REM On Windows the binary suffix is always windows-amd64
set "SUFFIX=%CLANG_VERSION%_windows-amd64"

echo RELEASE_TAG  = %RELEASE_TAG%
echo CLANG_VERSION = %CLANG_VERSION%
echo SUFFIX        = %SUFFIX%
echo PREFIX        = %PREFIX%

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\share\clang-tools-static" mkdir "%PREFIX%\share\clang-tools-static"

REM ------------------------------------------------------------------
REM Download, verify, and install each tool
REM ------------------------------------------------------------------
for %%t in (%TOOLS%) do (
    set "BINARY_NAME=%%t-%SUFFIX%.exe"
    set "CHECKSUM_NAME=%%t-%SUFFIX%.exe.sha512sum"
    set "DEST=%PREFIX%\bin\%%t-%CLANG_VERSION%.exe"

    echo.
    echo --- %%t ---

    REM Download binary
    echo   Downloading !BINARY_NAME! ...
    curl -fSL --retry 3 --retry-delay 10 ^
        -o "!DEST!" ^
        "%RELEASE_URL%/!BINARY_NAME!"
    if errorlevel 1 exit /b 1

    REM Download checksum
    echo   Downloading !CHECKSUM_NAME! ...
    curl -fSL --retry 3 --retry-delay 10 ^
        -o "%TEMP%\conda-clang-tools.sha512" ^
        "%RELEASE_URL%/!CHECKSUM_NAME!"
    if errorlevel 1 exit /b 1

    REM Verify SHA-512
    echo   Verifying SHA-512 ...
    REM Windows doesn't have sha512sum; we use certutil
    for /f "tokens=1" %%h in (%TEMP%\conda-clang-tools.sha512) do set "EXPECTED_HASH=%%h"

    REM Compute actual hash with certutil
    certutil -hashfile "!DEST!" SHA512 > "%TEMP%\conda-actual-hash.txt"
    REM certutil output is multiline; second line has the hash
    for /f "skip=1 delims=" %%a in (%TEMP%\conda-actual-hash.txt) do (
        set "ACTUAL_HASH=%%a"
        goto :hash_done
    )
    :hash_done
    REM Remove spaces
    set "ACTUAL_HASH=!ACTUAL_HASH: =!"

    if /i not "!EXPECTED_HASH!"=="!ACTUAL_HASH!" (
        echo ERROR: SHA-512 mismatch for !BINARY_NAME!
        echo   expected: !EXPECTED_HASH!
        echo   got:      !ACTUAL_HASH!
        exit /b 1
    )
    echo   SHA-512 OK

    echo   Installed !DEST!
)

REM ------------------------------------------------------------------
REM Install versions.json for reference (best-effort)
REM ------------------------------------------------------------------
echo.
echo --- versions.json (best-effort) ---
curl -fSL --retry 2 --retry-delay 5 ^
    -o "%PREFIX%\share\clang-tools-static\versions.json" ^
    "%RELEASE_URL%/versions.json" 2>nul || ^
    echo   (versions.json not available in this release - will be present in future releases)

echo.
echo Installation complete.
dir "%PREFIX%\bin"
