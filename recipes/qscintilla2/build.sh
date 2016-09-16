#!/bin/bash
BIN=$PREFIX/bin
QT_MAJOR_VER=`${BIN}/qmake -v | sed -n 's/.*Qt version \([0-9])*\).*/\1/p'`
if [ -z "$QT_MAJOR_VER" ]; then
	echo "Could not determine Qt version of string provided by qmake:"
	echo `qmake -v`
	echo "Aborting..."
	exit 1
else
	echo "Building Qscintilla for Qt${QT_MAJOR_VER}"
fi

# Set build specs depending on current platform (Mac OS X or Linux)
if [ `uname` == Darwin ]; then
	BUILD_SPEC=macx-llvm
else
	BUILD_SPEC=linux-g++
fi

# Go to Qscintilla source dir and then to its Qt4Qt5 folder.
cd ${SRC_DIR}/Qt4Qt5
# Build the makefile with qmake, specify llvm as the compiler
# The normal g++ compiler on Mac causes an __Unwind_Resume error at linking phase
${BIN}/qmake qscintilla.pro -spec ${BUILD_SPEC}
# Build Qscintilla
make
# and install it
make install

## Build Python module ##

# Go to python folder
cd ${SRC_DIR}/Python
# Configure compilation of Python Qsci module
${PYTHON} configure.py --pyqt=PyQt${QT_MAJOR_VER} --qmake=${BIN}/qmake --sip=${BIN}/sip --qsci-incdir=${PREFIX}/include/qt --qsci-libdir=${PREFIX}/lib --spec=${BUILD_SPEC} --no-qsci-api 
# make it
make

# On OSX: Change reference from libQsci.dylib to Qsci.so (otherwise anaconda linker crashes)
if [ `uname` == Darwin ]; then
	install_name_tool -id Qsci.so Qsci.so
fi

# Install QSci.so to the site-packages/PyQt4 folder
make install