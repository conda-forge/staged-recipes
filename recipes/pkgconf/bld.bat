meson --prefix=%LIBRARY_PREFIX% ^
    --libdir=%LIBRARY_PREFIX%\lib ^
    --buildtype=release ^
    --wrap-mode=nofallback ^
    build || goto :error
meson compile -C build -v || goto :error
meson install -C build || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
