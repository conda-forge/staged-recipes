@echo on
@setlocal EnableDelayedExpansion

meson %MESON_ARGS% ^
    --wrap-mode=nofallback ^
    build ^
    -Dtests=enabled || goto :error
meson compile -C build -v || goto :error
meson test -C build || goto :error
meson install -C build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
