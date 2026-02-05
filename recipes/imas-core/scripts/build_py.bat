:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: Build and install by pip with meson-python backend (PEP)
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv ^
    -Csetup-args=-Dal_core=false ^
    -Csetup-args=-Dpython_bindings=true
if %ERRORLEVEL% neq 0 exit 1