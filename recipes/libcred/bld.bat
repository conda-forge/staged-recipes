meson setup builddir --buildtype=release --prefix=%LIBRARY_PREFIX% --libdir=lib %MESON_ARGS%
cd builddir
ninja
ninja install