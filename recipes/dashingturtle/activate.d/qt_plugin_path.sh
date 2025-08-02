#!/bin/bash
PY_VER=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export QT_QPA_PLATFORM_PLUGIN_PATH="${CONDA_PREFIX}/lib/python${PY_VER}/site-packages/PyQt6/Qt6/plugins/platforms"
