# Overwrite the setup.py with ours while we patch things upstream
# Upstream likes to use crlf, which is really annoying to patch for
# hmaarrfk
# Patch included as reference
cp $RECIPE_DIR/setup.py .
# Need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} $(pkg-config --cflags libopenjp2)"

$PYTHON -m pip install . -vv
