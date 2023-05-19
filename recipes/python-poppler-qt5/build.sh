echo "[tool.sip.builder]
qmake-settings = [
  \"QMAKE_CXX = $CXX\"
]
" >> pyproject.toml
PKG_CONFIG_PATH=$CONDA_PREFIX_1/lib/pkgconfig sip-install --verbose
