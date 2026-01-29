:: Set version for setuptools_scm
set SETUPTOOLS_SCM_PRETEND_VERSION="%PKG_VERSION%"

:: binary is called `pkg-config`, but package metadata is under `lib/pkgconfig`
set MESON_ARGS=%MESON_ARGS% --pkg-config-path=%LIBRARY_PREFIX%/lib/pkgconfig

:: Build and install by pip with meson-python backend (PEP)
%PYTHON% -m pip install . --no-deps --no-build-isolation -vv ^
    -Csetup-args=-Dal_core=false ^
    -Csetup-args=-Dpython_bindings=true
