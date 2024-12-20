$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig;${env:PREFIX}/share/pkgconfig;${env:BUILD_PREFIX}/lib/pkgconfig"

# Split off last part of the version string
$_pkg_version = $env:PKG_VERSION -replace "\.[^.]+$", ""
& "./bootstrap-$_pkg_version" --prefix=$(pkg-config --variable=prefix mono)
# This should find the PREFIX mono (check for cross-compilation)
& "./configure" `
    --prefix=$(pkg-config --variable=prefix mono) `
    --disable-static
& "make"
& "make install"
