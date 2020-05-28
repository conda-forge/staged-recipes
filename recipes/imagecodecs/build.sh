# Copy over our setup.py file
cp ${RECIPE_DIR}/setup.py ${SRC_DIR}/setup.py

# need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} `pkg-config --cflags libopenjp2`"
export CFLAGS="${CFLAGS} -I${PREFIX}/include/jxrlib"

$PYTHON -m pip install . -vv

