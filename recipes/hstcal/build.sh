PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export PKG_CONFIG_PATH
./waf configure --prefix=${PREFIX} --release-with-symbols
./waf build
./waf install
