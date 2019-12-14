# The setup file located in the pypi directory doesn't match up with
# the one on the github repository tagged 2019.11.18
# I took the setup.py file the master branch and added some
# logic to detect the inclusion of jpeg12

# need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} `pkg-config --cflags libopenjp2`"
export CFLAGS="${CFLAGS} -I${PREFIX}/include/jxrlib"

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

