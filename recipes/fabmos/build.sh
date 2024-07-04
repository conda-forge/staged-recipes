cat > "${SRC_DIR}/setup.cfg" << EOL
[build_ext]
cmake_opts=${CMAKE_ARGS}
EOL
"${PYTHON}" -m pip install . -vv
