#!/bin/bash
set -euxo pipefail

# wheel/tar install
$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels pysam
$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels varnaapi
$PYTHON -m pip install $SRC_DIR/conda-recipe/wheels/mysql-connector-2.2.9.tar.gz
$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels PyQt6
$PYTHON -m pip install $SRC_DIR/conda-recipe/wheels/pyqt6_sip-13.10.2.tar.gz
$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels PyQt6-Qt6

# Install the package using pip
$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Rename the original executable installed by setup.py
mv "$PREFIX/bin/dt-gui" "$PREFIX/bin/.dt-gui-real"

PY_VER=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

cat > "$PREFIX/bin/dt-gui" <<EOF
#!/bin/bash

PLUGIN_CANDIDATES=(
  "\$CONDA_PREFIX/lib/python$PY_VER/site-packages/PyQt6/Qt6/plugins/platforms"
  "\$CONDA_PREFIX/lib/python$PY_VER/site-packages/PyQt6/Qt/plugins/platforms"
  "\$CONDA_PREFIX/Library/lib/python$PY_VER/site-packages/PyQt6/Qt6/plugins/platforms"
  "\$CONDA_PREFIX/Library/plugins/platforms"
)

for path in "\${PLUGIN_CANDIDATES[@]}"; do
  if [ -d "\$path" ]; then
    export QT_QPA_PLATFORM_PLUGIN_PATH="\$path"
    break
  fi
done

exec "\$CONDA_PREFIX/bin/.dt-gui-real" "\$@"
EOF

chmod +x "$PREFIX/bin/dt-gui"
