@echo on
setlocal EnableDelayedExpansion

:: Windows counterpart of build.sh; see the comments there for the reasoning behind each step.

set "CARGO_PROFILE_RELEASE_STRIP=symbols"
set "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1"
set "NPM_CONFIG_AUDIT=false"
set "NPM_CONFIG_FUND=false"
set "NPM_CONFIG_UPDATE_NOTIFIER=false"
set "npm_config_arch=x64"
set "NODE_OPTIONS=--max-old-space-size=6144"
for /f "tokens=4 delims=." %%a in ("%PKG_VERSION%") do set "POSITRON_BUILD_NUMBER=%%a"
set "npm_config_python=%BUILD_PREFIX%\python.exe"
:: positron-python's gulpfile looks for `python3`, which conda doesn't provide on Windows
set "CI_PYTHON_PATH=%BUILD_PREFIX%\python.exe"
for %%i in ("%SRC_DIR%\..") do set "GIT_CEILING_DIRECTORIES=%%~fi"

:: Windows path-length limits: keep cargo's registry/git checkouts under a short path
:: (conda's long build prefix pushes some dependency files past MAX_PATH)
set "CARGO_HOME=C:\ch"
mkdir "%CARGO_HOME%" 2>nul
set "CARGO_NET_GIT_FETCH_WITH_CLI=true"
git config --global core.longpaths true
git config --global core.autocrlf false

:: --- minimal local git repos for the submodule/postinstall scripts ---
call :git_snapshot extensions\positron-r\ark || exit /b 1
call :git_snapshot ai-lib || exit /b 1
call :git_snapshot . || exit /b 1

:: --- Rust components, built from source ---
pushd extensions\positron-r\ark
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY-ark.yml" || exit /b 1
cargo install --bins --no-track --locked --root "%SRC_DIR%\_bin" --path crates\ark || exit /b 1
popd
mkdir extensions\positron-r\ark\target\release
copy /y _bin\bin\ark.exe extensions\positron-r\ark\target\release\ark.exe || exit /b 1

pushd _kallichore
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY-kallichore.yml" || exit /b 1
cargo install --bins --no-track --locked --root "%SRC_DIR%\_bin" --path crates\kcserver || exit /b 1
popd
mkdir extensions\positron-supervisor\resources\kallichore
copy /y _bin\bin\kcserver.exe extensions\positron-supervisor\resources\kallichore\ || exit /b 1
<nul set /p "=%KALLICHORE_VERSION%" > extensions\positron-supervisor\resources\kallichore\VERSION

pushd _pet
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY-pet.yml" || exit /b 1
cargo install --bins --no-track --locked --root "%SRC_DIR%\_bin" --path crates\pet || exit /b 1
popd
mkdir extensions\positron-python\python-env-tools
mkdir extensions\positron-python\resources\pet
copy /y _bin\bin\pet.exe extensions\positron-python\python-env-tools\ || exit /b 1
<nul set /p "=%PET_VERSION%" > extensions\positron-python\resources\pet\VERSION

:: free disk
rmdir /s /q _kallichore\target _pet\target 2>nul
if defined CARGO_HOME ( rmdir /s /q "%CARGO_HOME%\registry" "%CARGO_HOME%\git" 2>nul )

:: --- vendored pure-python libraries for positron-python (patch 0002) ---
python -m pip install --no-deps --no-build-isolation --no-index --target "%SRC_DIR%\_pysrc" .\_pysrc_src\cattrs .\_pysrc_src\pydantic || exit /b 1
set "CONDA_VENDOR_SCRIPT=%RECIPE_DIR%\copy_from_env.py"
set "CONDA_VENDOR_PATHS=%SRC_DIR%\_pysrc;%BUILD_PREFIX%\Lib\site-packages"
set "CONDA_VENDOR_ALLOW_MISMATCH=typing-extensions"
set "CONDA_VENDOR_LICENSES=%SRC_DIR%\_vendored_licenses"

set "npm_config_build_from_source=true"

:: --- Positron ---
set "NPM_CONFIG_CACHE=%SRC_DIR%\.npm-cache"
set "CI=1"
call npm ci --no-audit --no-fund || exit /b 1
set "CI="
rmdir /s /q "%NPM_CONFIG_CACHE%" 2>nul
call npm run gulp vscode-win32-x64-min || exit /b 1

:: --- install ---
rmdir /s /q node_modules build\node_modules remote\node_modules out out-build out-vscode-min .build _bin 2>nul
for /d %%d in (extensions\*) do if exist "%%d\node_modules" rmdir /s /q "%%d\node_modules"
mkdir "%LIBRARY_PREFIX%\lib"
move "%SRC_DIR%\..\VSCode-win32-x64" "%LIBRARY_PREFIX%\lib\positron" || exit /b 1

:: launcher on PATH
mkdir "%LIBRARY_BIN%"
(
  echo @echo off
  echo call "%%~dp0..\lib\positron\bin\positron.cmd" %%*
) > "%LIBRARY_BIN%\positron.cmd"

:: use conda-forge's ripgrep instead of the prebuilt rg.exe downloaded by @vscode/ripgrep
for /r "%LIBRARY_PREFIX%\lib\positron\resources\app\node_modules.asar.unpacked\@vscode" %%f in (rg.exe) do (
  if exist "%%f" copy /y "%BUILD_PREFIX%\Library\bin\rg.exe" "%%f" || exit /b 1
)

:: desktop integration (menuinst)
mkdir "%PREFIX%\Menu"
copy /y "%RECIPE_DIR%\positron.json" "%PREFIX%\Menu\positron.json" || exit /b 1
copy /y "%LIBRARY_PREFIX%\lib\positron\resources\app\resources\win32\positron.ico" "%PREFIX%\Menu\positron.ico" || exit /b 1

python "%RECIPE_DIR%\collect_licenses.py" "%LIBRARY_PREFIX%\lib\positron\resources\app" "%SRC_DIR%\third-party-licenses" || exit /b 1
exit /b 0

:git_snapshot
git -C "%~1" init -q || exit /b 1
git -C "%~1" add -A || exit /b 1
git -C "%~1" -c user.name=conda-forge -c user.email=conda-forge@users.noreply.github.com commit -q --no-verify -m "source snapshot" || exit /b 1
exit /b 0
