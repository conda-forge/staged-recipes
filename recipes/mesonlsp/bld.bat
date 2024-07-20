meson --prefix=%LIBRARY_PREFIX% ^
    --libdir=%LIBRARY_PREFIX%\lib ^
    --buildtype=release ^
    build || goto :error
meson compile -C build -v || goto :error
meson install -C build || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
