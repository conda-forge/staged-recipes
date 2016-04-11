#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # We disable zmq version checking which fails under certain compile conditions.
    # The tests after building are assertion enough that we have built correctly.
    echo "[global]" > setup.cfg
    echo "skip_check_zmq = True" >> setup.cfg
fi

"${PYTHON}" setup.py configure --zmq "${PREFIX}"
"${PYTHON}" setup.py install
