#!/bin/bash

export JCC_JDK=$PREFIX
export JAVA_HOME=$JCC_JDK
export JAVAHOME=$JCC_JDK

if [ "$(uname)" == "Darwin" ]
then
    # OSX recipe
    export LD_LIBRARY_PATH=$PREFIX/jre/lib/amd64/server:$PREFIX/jre/lib/amd64:$LD_LIBRARY_PATH
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export MACOSX_VERSION_MIN=10.9

    $PYTHON setup.py install

else
    # GNU/Linux recipe
    export JCC_ARGSEP=";"
	export JCC_INCLUDES="$PREFIX/include;$PREFIX/include/linux"
	export JCC_LFLAGS="-L$PREFIX/jre/lib/amd64;-ljava;-L$PREFIX/jre/lib/amd64/server;-ljvm;-lverify;-Wl,-rpath=$PREFIX/jre/lib/amd64:$PREFIX/jre/lib/amd64/server"
	export JCC_JAVAC=$PREFIX/bin/javac
	# export LD_LIBRARY_PATH=$PREFIX/jre/lib/amd64/server:$PREFIX/jre/lib/amd64:$LD_LIBRARY_PATH
	# -L$PREFIX/lib/python3.6/lib-dynload
	printenv

	$PYTHON setup.py install

fi



# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
