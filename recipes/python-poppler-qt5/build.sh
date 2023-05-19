echo "[tool.sip.builder]
qmake-settings = [
  \"QMAKE_CXX = $CXX\"
]
" >> pyproject.toml
PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig sip-install --verbose
