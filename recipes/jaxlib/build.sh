#!/bin/bash

# Copying https://github.com/conda-forge/tensorflow-feedstock/blob/master/recipe/build.sh

if [ `uname` == Darwin ]; then
    WHL_FILE=https://files.pythonhosted.org/packages/f1/7b/ab3923ed21a9096d282c4c4bd22952a0ef8c6cda64c7e4a4c7ec9b0ee596/jaxlib-${PKG_VERSION}-py3-none-macosx_10_9_x86_64.whl
fi

if [ `uname` == Linux ]; then
    WHL_FILE=https://files.pythonhosted.org/packages/3a/2f/988d01f22d7a2019f0088d7e244fc2ef3aafb9052550783b742d70e01d88/jaxlib-${PKG_VERSION}-py3-none-manylinux1_x86_64.whl
fi

pip install --no-deps $WHL_FILE