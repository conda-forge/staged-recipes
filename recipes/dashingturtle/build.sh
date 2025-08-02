#!/bin/bash
set -euxo pipefail

#echo "SRC_DIR=$SRC_DIR"
#ls -R "$SRC_DIR"


# Create target directories inside the Conda environment prefix
mkdir -p "$PREFIX/share/dashingturtle/wheels"
mkdir -p "$PREFIX/share/dashingturtle/tarballs"

# Copy wheel files from source
cp "$SRC_DIR"/conda-recipe/wheels/*.whl "$PREFIX/share/dashingturtle/wheels/"

# Copy tar files from source
cp "$SRC_DIR"/conda-recipe/wheels/*.tar* "$PREFIX/share/dashingturtle/tarballs/"

$PYTHON -m pip install --no-index --find-links=$PREFIX/share/dashingturtle/wheels varnaapi

if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    echo "Running in GitHub Actions CI"
    IS_CI=true
else
    echo "Running..."
    IS_CI=false
   $PYTHON -m pip install $PREFIX/share/dashingturtle/tarballs/mysql-connector-2.2.9.tar.gz
   #$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels stack-data
   #$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels svgpathtools
   $PYTHON -m pip install --no-index --find-links=$PREFIX/share/dashingturtle/wheels PyQt6 PyQt6-sip PyQt6-Qt6
   #$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels matplotlib
   #$PYTHON -m pip install pysam
fi

#if [[ "$(uname)" == "Darwin" ]]; then
  #$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels PyQt6 PyQt6-sip PyQt6-Qt6
  #$PYTHON -m pip install --no-index --find-links=$SRC_DIR/conda-recipe/wheels snowflake-id
  #$PYTHON -m pip install pysam --no-index --find-links=$SRC_DIR/conda-recipe/wheels/pysam-0.23.3-cp39-cp39-macosx_11_0_arm64.whl
#fi

# Install the package using pip
cd "$SRC_DIR"
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
