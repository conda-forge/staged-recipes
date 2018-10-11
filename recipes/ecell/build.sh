#!/bin/bash

# install using pip from the whl files on PyPI

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://files.pythonhosted.org/packages/c3/fa/c1cf3e3e34b4531c57fe1de48e6537d02dc2751e29772a5533160a475dd7/ecell-4.1.4-cp27-cp27m-macosx_10_13_x86_64.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://files.pythonhosted.org/packages/58/47/25f3805cb1bece756534cc2b3804f033fcefea46bd86991fa951a1099c10/ecell-4.1.4-cp36-cp36m-macosx_10_13_x86_64.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "2.7" ]; then
        WHL_FILE=https://files.pythonhosted.org/packages/9c/83/56187fd22ff03d06a64ec15c7a6ee1965f4d47edb64efe935731306d8cd8/ecell-4.1.4-cp27-cp27mu-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.5" ]; then
        WHL_FILE=https://files.pythonhosted.org/packages/5b/63/f9d19d9b604f26b2a68cd483f1fff5f9169aede109e959edbc60c8d9c457/ecell-4.1.4-cp35-cp35m-manylinux1_x86_64.whl
    elif [ "$PY_VER" == "3.6" ]; then
        WHL_FILE=https://files.pythonhosted.org/packages/48/8d/d6faf2a379d58761881aec2fe2c4c8e4e198fe81dc8ff4625299816f6e0a/ecell-4.1.4-cp36-cp36m-manylinux1_x86_64.whl
    fi
fi

pip install --no-deps $WHL_FILE
