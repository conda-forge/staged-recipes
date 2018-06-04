#!/bin/bash
# install using pip from the whl files on PyPI

if [ "$PY_VER" == "2.7" ]; then
    WHL_FILE=https://files.pythonhosted.org/packages/4c/6e/95b8705958727580f0168fa210856ac14db31c69f0e3ea2bb53b57a5c268/gputools-${PKG_VERSION}-py2-none-any.whl
elif [ "$PY_VER" == "3.5" ]; then
    WHL_FILE=https://files.pythonhosted.org/packages/69/59/6cddcc42db5feeddbaa0b92605e544698f0ecf00b6b8c25c5aa623d97513/gputools-${PKG_VERSION}-py3-none-any.whl
elif [ "$PY_VER" == "3.6" ]; then
    WHL_FILE=https://files.pythonhosted.org/packages/69/59/6cddcc42db5feeddbaa0b92605e544698f0ecf00b6b8c25c5aa623d97513/gputools-${PKG_VERSION}-py3-none-any.whl
fi

pip install --no-deps $WHL_FILE