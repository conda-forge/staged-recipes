BUILD_TYPE=Release

# Configure pyGPlates.
#
# Note that CMAKE_BUILD_TYPE is ignored for multi-configuration tools (eg, Visual Studio).
# Note that CMAKE_INSTALL_PREFIX refers to Python's site-packages location.
# Note that CMAKE_FIND_FRAMEWORK (macOS) is set to LAST to avoid finding frameworks
#      (like Python and Qwt) outside the conda environment (it seems conda doesn't use frameworks).
cmake -G "$CMAKE_GENERATOR" \
      -D CMAKE_BUILD_TYPE=$BUILD_TYPE \
      -D GPLATES_BUILD_GPLATES=FALSE \
      -D GPLATES_INSTALL_STANDALONE=FALSE \
      -D "CMAKE_PREFIX_PATH=$PREFIX" \
      -D "CMAKE_INSTALL_PREFIX=$SP_DIR" \
      -D CMAKE_FIND_FRAMEWORK=LAST \
      "$SRC_DIR"

# Compile pyGPlates.
#
# Note that '--config' is only used by multi-configuration tools (eg, Visual Studio).
cmake --build . --config $BUILD_TYPE --target install-into-python
