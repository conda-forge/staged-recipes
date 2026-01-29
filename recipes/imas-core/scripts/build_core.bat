:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: Set Boost paths (make sure Meson finds the correct Boost installation)
set BOOST_LIBRARYDIR="%LIBRARY_PREFIX%/lib"
set BOOST_INCLUDEDIR="%LIBRARY_PREFIX%/include"

:: binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
set MESON_ARGS=%MESON_ARGS% --pkg-config-path=%LIBRARY_PREFIX%/lib/pkgconfig

:: Configure
:: TODO: Enable UDA backend when UDA package with dll built capnproto is available
meson setup build %MESON_ARGS% ^
    -D al_core=true ^
    -D al_backend_uda=false ^
    -D python_bindings=false

:: Build and install
meson install -C build
