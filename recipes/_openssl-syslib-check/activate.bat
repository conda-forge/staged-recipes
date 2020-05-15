:: Check whether there are dlls for openssl on the system path that would gets
:: picked up by the windows loader before those in the conda environment.
:: If yes, warn that the environment is potentially vulnerable.

@echo off

:: early out for users who want to silence the warning
if defined CONDA_SKIP_OPENSSL_DLL_CHECK (
  exit /b 0
)

set "LIBSSL_PATH=C:\Windows\System32\libssl-1_1-x64.dll"
set "LIBCRYPTO_PATH=C:\Windows\System32\libcrypto-1_1-x64.dll"

set "HAS_SYS_LIBS=F"
set "HAS_SYS_SSL=F"
set "HAS_SYS_CRYPTO=F"
if exist %LIBSSL_PATH% (
  set "HAS_SYS_LIBS=T"
  set "HAS_SYS_SSL=T"
)
if exist %LIBCRYPTO_PATH% (
  set "HAS_SYS_LIBS=T"
  set "HAS_SYS_CRYPTO=T"
)

:: early exit in case no syslibs are found
if "%HAS_SYS_LIBS%"=="F" (
  exit /b 0
)

:: if we made it until here, we need to detect if cryptography is installed
python -c "import cryptography" 2>nul
if %ERRORLEVEL% neq 0 (
  set "HAS_CRYPTOGRAPHY=F"
) else (
  set "HAS_CRYPTOGRAPHY=T"
)
:: reset ERRORLEVEL; see bottom of file for definition of reset_error
call :reset_error

:: If there is no python (resp. cryptography), we can only warn, since if anything wants to load
:: openssl *from outside of python*, not even CONDA_DLL_SEARCH_MODIFICATION_ENABLE will help.
:: (note: the carets are used for escaping brackets, which would otherwise be interpreted - and fail)
if "%HAS_CRYPTOGRAPHY%"=="F" (
                             ECHO WARNING: Your system contains ^(potentially^) outdated DLLs under:
  if "%HAS_SYS_SSL%"=="T"    ECHO WARNING: %LIBSSL_PATH%
  if "%HAS_SYS_CRYPTO%"=="T" ECHO WARNING: %LIBCRYPTO_PATH%
                             ECHO WARNING: These DLLs will be linked to before those in the conda
                             ECHO WARNING: environment and might make your installation vulnerable!!
                             ECHO Info:    ^(You can silence this warning by setting the environment
                             ECHO Info:    variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.^)
                             exit /b 0
)

:: Now we detect if the openssl-version in the conda environment matches the one that
:: cryptography loads (using the windows loader). For the latter, we want the full version
:: text (with format "OpenSSL 1.1.[01][a-z]  dd MMM yyyy"), as well as the version itself;
:: this is the second token after separating on spaces (which is the default for delims).
for /f "delims=" %%i in ('python -c "from cryptography.hazmat.backends.openssl import backend; print(backend.openssl_version_text())"') do set "LINKED_VERSION_TEXT=%%i"
for /f "tokens=2" %%i in ("%LINKED_VERSION_TEXT%") do set "LINKED_VERSION=%%i"

:: There are cases when even within the environment, `openssl version` will pick up the
:: wrong version (e.g. possibly if git is installed in the environment). Therefore we take
:: the information from conda itself. Using `conda list openssl` would also return info on
:: pyopenssl (if installed), so we use `conda list "^openssl"`, where the caret needs to be
:: escaped (with another caret) for evaluation within a batch subcommand. The following will
:: set the result to the second token of the *last line* from the output of `conda list ...`
for /f "tokens=2" %%i in ('conda list "^^openssl"') do set "ENV_VERSION=%%i"

:: determine if syslib is outdated, but let's not try to implement proper string ordering in batch...
for /f %%i in ('python -c "print(\"%LINKED_VERSION%\" < \"%ENV_VERSION%\")"') do set "LINKED_TO_OUTDATED_SYSLIB=%%i"

:: for debugging
:: echo Found LINKED_VERSION=%LINKED_VERSION%, ENV_VERSION=%ENV_VERSION%, LINKED_TO_OUTDATED_SYSLIB=%LINKED_TO_OUTDATED_SYSLIB%.

if "%LINKED_TO_OUTDATED_SYSLIB%"=="True" (
  REM If an older syslib is used even with CONDA_DLL_SEARCH_MODIFICATION_ENABLE
  REM already set, there's nothing more we can do than to warn the user.
  REM (note: using "::"-comments in if-blocks can lead to weird warnings/errors, but "REM" works)
  if defined CONDA_DLL_SEARCH_MODIFICATION_ENABLE (
                               ECHO WARNING: Your system contains outdated DLLs under:
    if "%HAS_SYS_SSL%"=="T"    ECHO WARNING: %LIBSSL_PATH%
    if "%HAS_SYS_CRYPTO%"=="T" ECHO WARNING: %LIBCRYPTO_PATH%
                               ECHO WARNING: using '%LINKED_VERSION_TEXT%' ^(instead of %ENV_VERSION% in the env^).
                               ECHO WARNING: These DLLs will be preferred over those in the conda env ^(despite
                               ECHO WARNING: our best tries^), and might make your installation vulnerable!
                               ECHO Info:    ^(Upgrading your python version should enable conda to work around
                               ECHO Info:    this; alternatively, you can silence this warning by setting the
                               ECHO Info:    environment variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.^)
  ) else (
    REM Otherwise, we set CONDA_DLL_SEARCH_MODIFICATION_ENABLE and try again.
    ECHO Warning: Found outdated libssl/libcrypto DLLs on system;
    ECHO Warning: Attempting to re-activate with CONDA_DLL_SEARCH_MODIFICATION_ENABLE
    ECHO.
    set CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1
    REM now we want to re-exec ourselves (cf. where activation is installed in bld.bat)
    call %PREFIX%\etc\conda\activate.d\_openssl-syslib-check_activate.bat
    if %ERRORLEVEL% neq 0 exit /b 1
  )
) else (
  REM If the correct version is linked because of CONDA_DLL_SEARCH_MODIFICATION_ENABLE,
  REM still emit a warning that linking to libssl & libcrypto might be vulnerable.
  if defined CONDA_DLL_SEARCH_MODIFICATION_ENABLE (
                               ECHO Warning: Your system contains outdated DLLs under:
    if "%HAS_SYS_SSL%"=="T"    ECHO Warning: %LIBSSL_PATH%
    if "%HAS_SYS_CRYPTO%"=="T" ECHO Warning: %LIBCRYPTO_PATH%
                               ECHO Warning: Within this environment, the python-runtime will correctly load
                               ECHO Warning: the openssl version of the environment, but be aware that anything
                               ECHO Warning: *outside* of python that is trying to load libssl/libcrypto will
                               ECHO Warning: load the DLLs above, which might make that application vulnerable!
                               ECHO Info:    ^(You can silence this warning by setting the environment
                               ECHO Info:    variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.^)
  )
  REM Otherwise, even though the system library will be preferred, its version is at least
  REM as up-to-date as the one in the conda environment, so no need to spam warnings.
)

:reset_error
exit /b 0
