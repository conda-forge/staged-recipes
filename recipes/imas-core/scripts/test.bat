:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

:: binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
set MESON_ARGS="%MESON_ARGS% --pkg-config-path=%LIBRARY_PREFIX%/lib/pkgconfig"

:: Configure
meson setup builddir %MESON_ARGS% ^
    -D al_core=false ^
    -D python_bindings=false ^
    -D al_dummy_exe=true ^
    -D al_test=true
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)

:: Run tests
meson test -C builddir --verbose
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)