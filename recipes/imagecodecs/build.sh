# Overwrite the setup.py with ours while we patch things upstream
# Upstream likes to use crlf, which is really annoying to patch for
# hmaarrfk
# Patch included as reference
cp $RECIPE_DIR/setup.py .
# Need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} $(pkg-config --cflags libopenjp2)"

# Setting LIBRARY_INC is a temporary workaround to enforce the conda-forge code path when building imagecodecs
# See https://github.com/conda-forge/staged-recipes/pull/10331#issuecomment-636441423
LIBRARY_INC="bogus" $PYTHON -m pip install . -vv
