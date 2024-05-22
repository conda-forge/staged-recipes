@echo on

set PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig

%PYTHON% -m pip install -vv --no-deps --no-build-isolation . || exit 1
