# Need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} $(pkg-config --cflags libopenjp2)"

# Setting LIBRARY_INC is a temporary workaround to enforce the conda-forge code path when building imagecodecs
# See https://github.com/conda-forge/staged-recipes/pull/10331#issuecomment-636441423
LIBRARY_INC="bogus" $PYTHON -m pip install . -vv
