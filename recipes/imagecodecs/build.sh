mv setup_modified.py setup.py

export ADDITIONAL_INCLUDE_PATHS=$PREFIX/include/jxrlib:$PREFIX/include/openjpeg-2.3

export JPEG8_INCLUDE=$PREFIX/include/jpeg8
export JPEG12_INCLUDE=$PREFIX/include/jpeg12

# it appears to be impossible to alter the command line of the Python extension compile
# call in such a manner, that the standard include dir is NOT the first look-up path
# as such, we move away the normal jpeg 8 headers, as elsewise we could never 
# let the compiler use the jpeg 12 ones ...

mkdir $JPEG8_INCLUDE

mv $PREFIX/include/jconfig.h $JPEG8_INCLUDE
mv $PREFIX/include/jmorecfg.h $JPEG8_INCLUDE
mv $PREFIX/include/jerror.h $JPEG8_INCLUDE
mv $PREFIX/include/jpeglib.h $JPEG8_INCLUDE

export CPATH=$ADDITIONAL_INCLUDE_PATHS:$CPATH
export LDSHARED=$CC

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

mv $JPEG8_INCLUDE/jconfig.h $PREFIX/include
mv $JPEG8_INCLUDE/jmorecfg.h $PREFIX/include
mv $JPEG8_INCLUDE/jerror.h $PREFIX/include
mv $JPEG8_INCLUDE/jpeglib.h $PREFIX/include

rmdir $JPEG8_INCLUDE
