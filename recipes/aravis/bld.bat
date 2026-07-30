
meson setup %MESON_ARGS% ^
    -Dviewer=disabled ^
    --prefix="%PREFIX%" ^
    builddir .

ninja  -C builddir -j%CPU_COUNT%
ninja  -C builddir install
