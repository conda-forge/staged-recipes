# The setup file located in the pypi directory doesn't match up with
# the one on the github repository tagged 2019.11.18
# I took the setup.py file the master branch and added some
# logic to detect the inclusion of jpeg12
cp ${RECIPE_DIR}/setup_master_jpeg12.py ${SRC_DIR}/setup.py

# need to add the openjpeg2 cflags
export CFLAGS="${CFLAGS} `pkg-config --cflags libopenjp2`"
export CFLAGS="${CFLAGS} -I${PREFIX}/include/jxrlib"

JPEG12_INCLUDE=$PREFIX/include/jpeg12
# I am adding this logic in an if statement to get a first version
# of the package uploaded to conda-forge while jpeg(-turbo)12 gets officially
# packaged
if [ -f "${JPEG12_INCLUDE}/jpeglib.h" ]; then
  # it appears to be impossible to alter the command line of the Python extension compile
  # call in such a manner, that the standard include dir is NOT the first look-up path
  # as such, we move away the normal jpeg 8 headers, as elsewise we could never
  # let the compiler use the jpeg 12 ones ...

  export JPEG8_INCLUDE=$PREFIX/include/jpeg8
  export JPEG12_INCLUDE

  mkdir $JPEG8_INCLUDE

  mv $PREFIX/include/jconfig.h $JPEG8_INCLUDE
  mv $PREFIX/include/jmorecfg.h $JPEG8_INCLUDE
  mv $PREFIX/include/jerror.h $JPEG8_INCLUDE
  mv $PREFIX/include/jpeglib.h $JPEG8_INCLUDE
fi

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

if [ -f "${JPEG12_INCLUDE}/jpeglib.h" ]; then
  mv $JPEG8_INCLUDE/jconfig.h $PREFIX/include
  mv $JPEG8_INCLUDE/jmorecfg.h $PREFIX/include
  mv $JPEG8_INCLUDE/jerror.h $PREFIX/include
  mv $JPEG8_INCLUDE/jpeglib.h $PREFIX/include

  rmdir $JPEG8_INCLUDE
fi
