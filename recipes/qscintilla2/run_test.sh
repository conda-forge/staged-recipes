#!/bin/bash

# Get QT version (4 or 5)
BIN=$PREFIX/bin
QT_MAJOR_VER=`${BIN}/qmake -v | sed -n 's/.*Qt version \([0-9])*\).*/\1/p'`
if [ -z "$QT_MAJOR_VER" ]; then
	echo "Could not determine Qt version of string provided by qmake:"
	echo `${BIN}/qmake -v`
	echo "Aborting..."
	exit 1
else
	echo "Building Qscintilla for Qt${QT_MAJOR_VER}"
fi

# Try to import Qsci from the retrieved Qt version
# ${PYTHON} -c "import PyQt${QT_MAJOR_VER}.Qsci"
python -c "import PyQt${QT_MAJOR_VER}.Qsci"