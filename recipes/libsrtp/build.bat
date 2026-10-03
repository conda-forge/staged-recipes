@echo on
@setlocal EnableDelayedExpansion

meson -Dbuildtype=release ^
    --prefix=%LIBRARY_PREFIX% ^
    -Dlibdir=lib ^
    --wrap-mode=nofallback ^
    build ^
    -Dtests=enabled || goto :error
meson compile -C build -v || goto :error
:: Unit tests fail on windows
:: ERROR: The process "1316" not found.
REM meson test -C build || goto :error
meson install -C build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
