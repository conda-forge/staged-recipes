cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

meson setup builddir ^
    --prefix="%LIBRARY_PREFIX%" ^
    --buildtype=release ^
    -Dwith_tests=false ^
    -Dwith_examples=false
if errorlevel 1 exit 1

ninja -C builddir
if errorlevel 1 exit 1

ninja -C builddir install
if errorlevel 1 exit 1
