@echo on
setlocal EnableDelayedExpansion

set "MSYSTEM=UCRT64"
if not defined CPU_COUNT set "CPU_COUNT=1"

echo === xmake build.bat starting ===

REM Source extraction workaround (native CMD)
if not exist configure (
    echo configure not found, extracting source...
    if exist .source_info.json (
        for /f "usebackq delims=" %%i in (`python -c "import json; print(json.load(open('.source_info.json')).get('source_cache', ''))" 2^>nul`) do set "SRC_CACHE=%%i"
        if defined SRC_CACHE (
            echo Source cache: !SRC_CACHE!
            for /r "!SRC_CACHE!" %%f in (*.tar.gz) do (
                if not defined TARBALL set "TARBALL=%%f"
            )
            if defined TARBALL (
                echo Found tarball: !TARBALL!
                tar xzf "!TARBALL!" --strip-components=1
                if !ERRORLEVEL! neq 0 (
                    echo ERROR: tar extraction failed
                    exit /b 1
                )
            ) else (
                echo ERROR: No .tar.gz found in !SRC_CACHE!
                exit /b 1
            )
        ) else (
            echo ERROR: source_cache not found in .source_info.json
            exit /b 1
        )
    ) else (
        echo ERROR: .source_info.json not found
        exit /b 1
    )
) else (
    echo configure already exists, skipping extraction
)

if not exist configure (
    echo ERROR: configure not found after extraction
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
