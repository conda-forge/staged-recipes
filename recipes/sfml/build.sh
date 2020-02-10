#!/bin/bash

cmake -D CMAKE_BUILD_TYPE=Release                 \
      -D CMAKE_INSTALL_PREFIX=$PREFIX             \
      -D UDEV_PATH_INCLUDES=$PREFIX/include       \
      -D UDEV_PATH_LIB=$PREFIX/lib                \
      -D CMAKE_INSTALL_LIBDIR=lib                 \
      -D CMAKE_PREFIX_PATH=$PREFIX                \
      -D SFML_DEPENDENCIES_INSTALL_PREFIX=$PREFIX \
      -D SFML_BUILD_EXAMPLES=OFF                  \
      -D SFML_BUILD_DOC=OFF                       \
      -D BUILD_SHARED_LIBS=ON                     \
      -D SFML_BUILD_FRAMEWORKS=OFF                \
      -D SFML_BUILD_AUDIO=ON                      \
      -D SFML_BUILD_GRAPHICS=ON                   \
      -D SFML_BUILD_WINDOW=ON                     \
      -D SFML_BUILD_NETWORK=ON                    \
      -D SFML_USE_SYSTEM_DEPS=ON                  \
      -D SFML_INSTALL_XCODE_TEMPLATES=OFF         \
      $SRC_DIR

make install
