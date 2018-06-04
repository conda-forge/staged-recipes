#!/bin/bash
# install using pip from the whl files on PyPI

if [ "$PY_VER" == "2.7" ]; then
	SHA=8a6c8a996f12e89a1229ddc9ca96ff9cbe66dcf60a8aed3e1799cd811c65ef20
    WHL_FILE=https://files.pythonhosted.org/packages/4c/6e/${SHA}/gputools-${PKG_VERSION}-py2-none-any.whl
elif [ "$PY_VER" == "3.5" ]; then
	SHA=6581a7811abc22974ec2c8637ea3e08a4b00d69c05cc12d3ea50132502c8d479
    WHL_FILE=https://files.pythonhosted.org/packages/69/59/${SHA}/gputools-${PKG_VERSION}-py3-none-any.whl
elif [ "$PY_VER" == "3.6" ]; then
	SHA=6581a7811abc22974ec2c8637ea3e08a4b00d69c05cc12d3ea50132502c8d479
    WHL_FILE=https://files.pythonhosted.org/packages/69/59/${SHA}/gputools-${PKG_VERSION}-py3-none-any.whl
fi

pip install --no-deps $WHL_FILE