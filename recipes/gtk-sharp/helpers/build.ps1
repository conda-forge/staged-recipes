$env:PKG_CONFIG_PATH = "${env:PREFIX}/lib/pkgconfig;${env:PREFIX}/share/pkgconfig;${env:BUILD_PREFIX}/lib/pkgconfig"

# Split off last part of the version string
$_pkg_version = $env:PKG_VERSION -replace "\.[^.]+$", ""
Invoke-CommandWithLogging "bash -c 'bootstrap-$_pkg_version --prefix=$env:PREFIX'"
Invoke-CommandWithLogging "bash -c 'configure --prefix=$env:PREFIX --disable-static'"
Invoke-CommandWithLogging "makw"
Invoke-CommandWithLogging "make install"
