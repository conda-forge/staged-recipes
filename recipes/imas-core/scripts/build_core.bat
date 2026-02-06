:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: Set Boost paths (make sure Meson finds the correct Boost installation)
set BOOST_LIBRARYDIR="%LIBRARY_PREFIX%/lib"
set BOOST_INCLUDEDIR="%LIBRARY_PREFIX%/include"

:: binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
set MESON_ARGS=--prefix=%LIBRARY_PREFIX% -Dbuildtype=release --pkg-config-path=%LIBRARY_PREFIX%/lib/pkgconfig

:: Configure
meson setup builddir %MESON_ARGS% ^
    -D al_core=true ^
    -D python_bindings=false ^
    -D cpp_std=c++17
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)

:: Build and install
meson install -C builddir
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)