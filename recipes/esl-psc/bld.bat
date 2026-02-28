@echo on
setlocal

cargo build --release --manifest-path esl_psc_rs\Cargo.toml
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
set "BIN_PATH="
for %%F in (
  "esl_psc_rs\target\release\esl-psc.exe"
  "esl_psc_rs\target\x86_64-pc-windows-msvc\release\esl-psc.exe"
  "esl_psc_rs\target\x86_64-pc-windows-gnu\release\esl-psc.exe"
  "target\release\esl-psc.exe"
  "target\x86_64-pc-windows-msvc\release\esl-psc.exe"
  "target\x86_64-pc-windows-gnu\release\esl-psc.exe"
) do (
  if exist %%~F (
    set "BIN_PATH=%%~F"
    goto found_bin
  )
)
for /f "delims=" %%F in ('dir /s /b esl-psc.exe ^| findstr /I "\\release\\esl-psc.exe$"') do (
  set "BIN_PATH=%%F"
  goto found_bin
)
if not defined BIN_PATH (
  echo could not find built binary esl-psc.exe in expected target directories
  exit /b 1
)
:found_bin
copy /Y "%BIN_PATH%" "%LIBRARY_BIN%\esl-psc.exe"
if errorlevel 1 exit /b 1

if not exist "%SP_DIR%\esl_psc_cli" mkdir "%SP_DIR%\esl_psc_cli"
xcopy /E /I /Y esl_psc_cli "%SP_DIR%\esl_psc_cli"
if errorlevel 1 exit /b 1

if not exist "%SP_DIR%\gui" mkdir "%SP_DIR%\gui"
if not exist "%SP_DIR%\gui\core" mkdir "%SP_DIR%\gui\core"
copy /Y gui\__init__.py "%SP_DIR%\gui\__init__.py"
if errorlevel 1 exit /b 1
copy /Y gui\core\fast_scan.py "%SP_DIR%\gui\core\fast_scan.py"
if errorlevel 1 exit /b 1
copy /Y gui\core\fasta_io.py "%SP_DIR%\gui\core\fasta_io.py"
if errorlevel 1 exit /b 1
copy /Y gui\core\ancestral_reconstruction.py "%SP_DIR%\gui\core\ancestral_reconstruction.py"
if errorlevel 1 exit /b 1
