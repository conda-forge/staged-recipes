#!/bin/bash

export JCC_JDK=$JAVA_HOME

if [ "$(uname)" == "Darwin" ]
then
    export JCC_ARGSEP=";"
    export JCC_INCLUDES="$PREFIX/include;$PREFIX/include/darwin"
	export JCC_LFLAGS="-v;-L$PREFIX/jre/lib;-ljava;-L$PREFIX/jre/lib/server;-ljvm;-Wl,-rpath;-Wl,$PREFIX/jre/lib;-Wl,-rpath;-Wl,$PREFIX/jre/lib/server;-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
	export JCC_CFLAGS="-fno-strict-aliasing;-Wno-write-strings;-Qunused-arguments;-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
    export NO_SHARED=1
    printenv

    $PYTHON setup.py install --single-version-externally-managed --record record.txt

else
    # GNU/Linux recipe
    export JCC_ARGSEP=";"
	export JCC_LFLAGS="-v;-L$PREFIX/jre/lib/amd64;-ljava;-L$PREFIX/jre/lib/amd64/server;-ljvm;-lverify;-Wl,-rpath=$PREFIX/jre/lib/amd64:$PREFIX/jre/lib/amd64/server"
	export JCC_JAVAC=$PREFIX/bin/javac
	export JCC_CFLAGS="-fno-strict-aliasing;-Wno-write-strings;-D__STDC_FORMAT_MACROS"

	printenv

	$PYTHON setup.py install --single-version-externally-managed --record record.txt

fi
# ensure that JCC_JDK is set correctly by invoking an activate script

ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/jcc-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/jcc-deactivate.sh