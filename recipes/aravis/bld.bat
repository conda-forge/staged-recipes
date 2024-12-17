
meson setup %MESON_ARGS% ^
    -Dviewer=enabled ^
    --prefix="%PREFIX%" ^
    builddir .

ninja  -C builddir -j%CPU_COUNT%
ninja  -C builddir install
