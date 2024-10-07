meson %MESON_ARGS% ^
    --wrap-mode=nofallback ^
    build ^
    -Dgdk-pixbuf2=disabled ^
    -Dtests=disabled || goto :error
meson compile -C build -v || goto :error
meson install -C build || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
