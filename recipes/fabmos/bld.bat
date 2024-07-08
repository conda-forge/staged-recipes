echo [build_ext]>"%SRC_DIR%\setup.cfg"
echo cmake_opts=-G "MinGW Makefiles" %CMAKE_ARGS%>>"%SRC_DIR%\setup.cfg"
"%PYTHON%" -m pip install . -vv
