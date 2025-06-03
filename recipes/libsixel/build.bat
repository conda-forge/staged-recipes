@echo on
@setlocal EnableDelayedExpansion

meson %MESON_ARGS% ^
    --wrap-mode=nofallback ^
    build ^
    -Dgdk-pixbuf2=enabled ^
    -Dtests=enabled || goto :error
meson compile -C build -v -j %CPU_COUNT% || goto :error
meson test -C build -j %CPU_COUNT% || goto :error
meson install -C build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
