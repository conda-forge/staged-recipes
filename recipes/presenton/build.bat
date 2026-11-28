@echo off
REM Build script for presenton (Windows)
REM Multi-component app: Python FastAPI backend + Next.js 14 frontend.
REM Installs to %PREFIX%\share\presenton\ with launchers in %PREFIX%\Scripts\.
setlocal enabledelayedexpansion

set PRESENTON_SHARE=%PREFIX%\share\presenton
set BACKEND_DST=%PRESENTON_SHARE%\backend
set NEXTJS_DST=%PRESENTON_SHARE%\nextjs

REM ---------------------------------------------------------------------------
REM Step 1: Build Next.js frontend
REM ---------------------------------------------------------------------------
echo =^> Building Next.js frontend...
cd /d "%SRC_DIR%\servers\nextjs"

REM Patch next.config.mjs to enable standalone output
python -c ^
"import re, sys; path='next.config.mjs'; c=open(path).read(); exit(0) if 'output:' in c else open(path,'w').write(re.sub(r'(const nextConfig\s*=\s*\{)', r'\1\n  output: \"standalone\",', c, count=1)) or print('Patched next.config.mjs')"
if errorlevel 1 goto :error

REM Install pnpm via npm (always available with nodejs; corepack may not
REM be in PATH in conda environments even when Node.js >=16.9 is present).
call npm install -g pnpm@10
if errorlevel 1 goto :error

REM Patch package.json for win32/x64 supportedArchitectures so pnpm downloads
REM only win32-x64 optional dependencies (avoids linux/darwin binaries in the package).
python -c "import json; p=json.load(open('package.json')); p.setdefault('pnpm',{})['supportedArchitectures']={'os':['win32'],'cpu':['x64'],'libc':['unknown']}; json.dump(p,open('package.json','w'),indent=2); print('package.json: supportedArchitectures -> win32/x64')"
if errorlevel 1 goto :error

REM node-linker=hoisted creates a fully flat node_modules (like npm) with real
REM file copies and no .pnpm/ virtual store. Benefits: TypeScript resolves
REM transitive type declarations, and the package contains no symlinks
REM (symlinks are not supported in Windows conda packages).
echo node-linker=hoisted>> .npmrc

call pnpm install --no-frozen-lockfile
if errorlevel 1 goto :error

call pnpm run build
if errorlevel 1 goto :error

cd /d "%SRC_DIR%"

REM ---------------------------------------------------------------------------
REM Step 2: Create installation directories
REM ---------------------------------------------------------------------------
echo =^> Creating installation directories...
mkdir "%BACKEND_DST%" 2>nul
mkdir "%NEXTJS_DST%" 2>nul

REM ---------------------------------------------------------------------------
REM Step 3: Copy Python backend
REM ---------------------------------------------------------------------------
echo =^> Copying Python backend...
set FASTAPI_SRC=%SRC_DIR%\servers\fastapi

for %%d in (api enums models services constants utils assets static) do (
    if exist "%FASTAPI_SRC%\%%d" (
        xcopy /E /I /Q "%FASTAPI_SRC%\%%d" "%BACKEND_DST%\%%d\"
    )
)

copy "%FASTAPI_SRC%\server.py" "%BACKEND_DST%\"
for %%f in (mcp_server.py migrations.py alembic.ini openai_spec.json) do (
    if exist "%FASTAPI_SRC%\%%f" copy "%FASTAPI_SRC%\%%f" "%BACKEND_DST%\"
)
if exist "%FASTAPI_SRC%\alembic" xcopy /E /I /Q "%FASTAPI_SRC%\alembic" "%BACKEND_DST%\alembic\"

REM ---------------------------------------------------------------------------
REM Step 4: Copy Next.js frontend (standalone bundle)
REM ---------------------------------------------------------------------------
echo =^> Copying Next.js frontend...
set NEXT_BUILD=%SRC_DIR%\servers\nextjs\.next-build

if exist "%NEXT_BUILD%\standalone" (
    xcopy /E /I /Q "%NEXT_BUILD%\standalone" "%NEXTJS_DST%\standalone\"
    mkdir "%NEXTJS_DST%\standalone\.next-build\static" 2>nul
    xcopy /E /I /Q "%NEXT_BUILD%\static" "%NEXTJS_DST%\standalone\.next-build\static\"
    if exist "%SRC_DIR%\servers\nextjs\public" (
        xcopy /E /I /Q "%SRC_DIR%\servers\nextjs\public" "%NEXTJS_DST%\standalone\public\"
    )
) else (
    echo WARNING: standalone output not found; copying full build + node_modules
    xcopy /E /I /Q "%NEXT_BUILD%" "%NEXTJS_DST%\.next-build\"
    xcopy /E /I /Q "%SRC_DIR%\servers\nextjs\node_modules" "%NEXTJS_DST%\node_modules\"
    if exist "%SRC_DIR%\servers\nextjs\public" (
        xcopy /E /I /Q "%SRC_DIR%\servers\nextjs\public" "%NEXTJS_DST%\public\"
    )
    copy "%SRC_DIR%\servers\nextjs\package.json" "%NEXTJS_DST%\"
)

REM ---------------------------------------------------------------------------
REM Step 5: Create launcher scripts
REM ---------------------------------------------------------------------------
echo =^> Creating launcher scripts...
mkdir "%PREFIX%\Scripts" 2>nul

REM -- presenton-backend.bat --------------------------------------------------
(
    echo @echo off
    echo REM Presenton FastAPI backend launcher
    echo set PRESENTON_SHARE=%%CONDA_PREFIX%%\share\presenton
    echo set PYTHONPATH=%%PRESENTON_SHARE%%\backend;%%PYTHONPATH%%
    echo cd /d "%%PRESENTON_SHARE%%\backend"
    echo if "%%PRESENTON_PORT%%"=="" set PRESENTON_PORT=8000
    echo python server.py --port %%PRESENTON_PORT%% %%*
) > "%PREFIX%\Scripts\presenton-backend.bat"

REM -- presenton-frontend.bat -------------------------------------------------
(
    echo @echo off
    echo REM Presenton Next.js frontend launcher
    echo set PRESENTON_SHARE=%%CONDA_PREFIX%%\share\presenton
    echo if "%%PRESENTON_FRONTEND_PORT%%"=="" set PRESENTON_FRONTEND_PORT=3000
    echo if exist "%%PRESENTON_SHARE%%\nextjs\standalone" ^(
    echo     cd /d "%%PRESENTON_SHARE%%\nextjs\standalone"
    echo     set PORT=%%PRESENTON_FRONTEND_PORT%%
    echo     node server.js
    echo ^) else ^(
    echo     cd /d "%%PRESENTON_SHARE%%\nextjs"
    echo     set PORT=%%PRESENTON_FRONTEND_PORT%%
    echo     npx next start
    echo ^)
) > "%PREFIX%\Scripts\presenton-frontend.bat"

echo =^> presenton installation complete.
echo     Run 'presenton-backend' to start the FastAPI server.
echo     Run 'presenton-frontend' to start the Next.js frontend.
goto :eof

:error
echo Build failed with error %errorlevel%
exit /b %errorlevel%
