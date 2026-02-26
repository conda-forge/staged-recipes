@echo on
setlocal EnableDelayedExpansion

set "MSYSTEM=UCRT64"
if not defined CPU_COUNT set "CPU_COUNT=1"

echo === xmake build.bat starting ===

REM Source extraction workaround (native CMD)
if not exist configure (
    echo configure not found, extracting source...
    if exist .source_info.json (
        echo === .source_info.json contents: ===
        type .source_info.json
        echo ===================================
        for /f "usebackq delims=" %%i in (`python -c "import json; d=json.load(open('.source_info.json')); print(d.get('source_cache', d.get('cache_path', '')))" 2^>nul`) do set "SRC_CACHE=%%i"
        if defined SRC_CACHE (
            echo Source cache: !SRC_CACHE!
            echo === Contents of source cache: ===
            if exist "!SRC_CACHE!\*" (
                dir /s /b "!SRC_CACHE!"
            ) else (
                echo source_cache is a file, not a directory
                dir "!SRC_CACHE!"
            )
            echo ================================
            REM Check if source_cache points directly to a file
            if exist "!SRC_CACHE!" if not exist "!SRC_CACHE!\*" (
                echo Using source_cache as tarball directly
                tar xzf "!SRC_CACHE!" --strip-components=1
                goto :extracted
            )
            REM Search recursively for tarballs
            set "TARBALL="
            for /r "!SRC_CACHE!" %%f in (*.tar.gz *.tgz *.tar.*) do (
                if not defined TARBALL set "TARBALL=%%f"
            )
            if defined TARBALL (
                echo Found tarball: !TARBALL!
                tar xzf "!TARBALL!" --strip-components=1
            ) else (
                echo No tarball found, trying first file in cache...
                for /f "delims=" %%f in ('dir /b /a-d "!SRC_CACHE!" 2^>nul') do (
                    if not defined TARBALL set "TARBALL=!SRC_CACHE!\%%f"
                )
                if defined TARBALL (
                    echo Trying file: !TARBALL!
                    tar xzf "!TARBALL!" --strip-components=1
                ) else (
                    echo ERROR: No files found in !SRC_CACHE!
                    exit /b 1
                )
            )
        ) else (
            echo ERROR: source_cache not found in .source_info.json
            exit /b 1
        )
    ) else (
        echo ERROR: .source_info.json not found
        exit /b 1
    )
)
:extracted

if not exist configure (
    echo ERROR: configure not found after extraction
    echo === Current directory contents: ===
    dir /b
    exit /b 1
)

REM Generate build script for MSYS2 bash
echo #!/bin/bash> _build.sh
echo set -euxo pipefail>> _build.sh
echo.>> _build.sh
echo PREFIX_UNIX=$(cygpath "$PREFIX")>> _build.sh
echo SRC_UNIX=$(cygpath "$SRC_DIR")>> _build.sh
echo cd "$SRC_UNIX">> _build.sh
echo.>> _build.sh
echo ./configure --prefix="$PREFIX_UNIX">> _build.sh
echo make -j%CPU_COUNT%>> _build.sh
echo make install PREFIX="$PREFIX_UNIX">> _build.sh

echo === Generated _build.sh: ===
type _build.sh
echo ===========================

REM Run via MSYS2 bash
bash -lc "chmod +x _build.sh && ./_build.sh"
if !ERRORLEVEL! neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo === Build completed successfully ===
