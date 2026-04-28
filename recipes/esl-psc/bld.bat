@echo on
setlocal

cargo auditable install --locked --no-track --bins --root %LIBRARY_PREFIX% --path esl_psc_rs
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
