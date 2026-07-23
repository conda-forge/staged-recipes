@echo on
setlocal EnableExtensions EnableDelayedExpansion

set "ENTRIES=source\isaaclab:isaaclab source\isaaclab_assets:isaaclab_assets source\isaaclab_contrib:isaaclab_contrib source\isaaclab_mimic:isaaclab_mimic source\isaaclab_rl:isaaclab_rl source\isaaclab_tasks:isaaclab_tasks"

@REM Install each extension package wheel-style and let conda own dependency solving.
for %%E in (%ENTRIES%) do (
    for /f "tokens=1,2 delims=:" %%A in ("%%E") do (
        "%PYTHON%" -m pip install "%%A" --no-build-isolation --no-deps
        if errorlevel 1 exit /b 1
    )
)

@REM Determine site-packages for the active build interpreter.
for /f "delims=" %%I in ('"%PYTHON%" -c "import sysconfig; print(sysconfig.get_path(\"purelib\"))"') do set "SITE_PACKAGES=%%I"
if not defined SITE_PACKAGES (
    echo Failed to determine site-packages path.
    exit /b 1
)

@REM Relocate sibling asset folders (config/data) under each module root.
for %%E in (%ENTRIES%) do (
    for /f "tokens=1,2 delims=:" %%A in ("%%E") do (
        set "EXT_ROOT=%%A"
        set "MODULE=%%B"
        set "SRC_MODULE=!EXT_ROOT!\!MODULE!"
        set "DST_MODULE=!SITE_PACKAGES!\!MODULE!"

        if not exist "!SRC_MODULE!\" (
            echo Missing module directory: !SRC_MODULE!
            exit /b 1
        )

        if not exist "!DST_MODULE!\" mkdir "!DST_MODULE!"
        robocopy "!SRC_MODULE!" "!DST_MODULE!" /E /NFL /NDL /NJH /NJS /NP >nul
        if errorlevel 8 exit /b 1

        if exist "!EXT_ROOT!\config\" (
            if exist "!DST_MODULE!\config\" rmdir /S /Q "!DST_MODULE!\config"
            robocopy "!EXT_ROOT!\config" "!DST_MODULE!\config" /E /NFL /NDL /NJH /NJS /NP >nul
            if errorlevel 8 exit /b 1
        )

        if exist "!EXT_ROOT!\data\" (
            if exist "!DST_MODULE!\data\" rmdir /S /Q "!DST_MODULE!\data"
            robocopy "!EXT_ROOT!\data" "!DST_MODULE!\data" /E /NFL /NDL /NJH /NJS /NP >nul
            if errorlevel 8 exit /b 1
        )
    )
)

@REM IsaacLab computes extension root as one level above the module directory.
@REM In conda we colocate package assets inside each module, so patch the root.
"%PYTHON%" -c "from pathlib import Path; import sys; site_packages=Path(sys.argv[1]); modules=('isaaclab','isaaclab_assets','isaaclab_contrib','isaaclab_tasks'); legacy='os.path.abspath(os.path.join(os.path.dirname(__file__), \"../\"))'; patched='os.path.abspath(os.path.dirname(__file__))'; exec('for module in modules:\\n    init_py = site_packages / module / \"__init__.py\"\\n    if not init_py.is_file():\\n        raise SystemExit(f\"Missing __init__.py for {module}: {init_py}\")\\n    text = init_py.read_text()\\n    if legacy in text:\\n        init_py.write_text(text.replace(legacy, patched))')" "%SITE_PACKAGES%"
if errorlevel 1 exit /b 1
