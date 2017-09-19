#!/bin/bash

# add --shared for building shared version
# classes directly on the list are wrapped as well as the jar's
# This section is setting up the build to use the coda package java-jdk
#export JCC_JDK=$PREFIX
#export JAVA_HOME=$JCC_JDK
#export JAVAHOME=$JCC_JDK
#export LD_LIBRARY_PATH=$PREFIX/jre/lib/amd64/server:$PREFIX/jre/lib/amd64:$LD_LIBRARY_PATH

#export JCC_ARGSEP=";"
#export JCC_INCLUDES="$PREFIX/include;$PREFIX/include/linux"
#export JCC_LFLAGS="-L$PREFIX/jre/lib/amd64;-ljava;-L$PREFIX/jre/lib/amd64/server;-ljvm;-lverify;-Wl,-rpath=$PREFIX/jre/lib/amd64:$PREFIX/jre/lib/amd64/server"
#export JCC_JAVAC=$PREFIX/bin/javac

export MACOSX_DEPLOYMENT_TARGET=10.9

$PYTHON -m jcc \
--use_full_names \
--python orekit \
--version 9.0 \
--jar $RECIPE_DIR/orekit-9.0.jar \
--jar $RECIPE_DIR/hipparchus-core-1.1.jar \
--jar $RECIPE_DIR/hipparchus-fitting-1.1.jar \
--jar $RECIPE_DIR/hipparchus-geometry-1.1.jar \
--jar $RECIPE_DIR/hipparchus-ode-1.1.jar \
--jar $RECIPE_DIR/hipparchus-optim-1.1.jar \
--jar $RECIPE_DIR/hipparchus-stat-1.1.jar \
--package java.io \
--package java.util \
--package java.text \
--package org.orekit \
java.io.BufferedReader \
java.io.FileInputStream \
java.io.FileOutputStream \
java.io.InputStream \
java.io.InputStreamReader \
java.io.ObjectInputStream \
java.io.ObjectOutputStream \
java.io.PrintStream \
java.io.StringReader \
java.io.StringWriter \
java.lang.System \
java.text.DecimalFormat \
java.text.DecimalFormatSymbols \
java.util.ArrayList \
java.util.Arrays \
java.util.Collection \
java.util.Collections \
java.util.Date \
java.util.HashMap \
java.util.HashSet \
java.util.List \
java.util.Locale \
java.util.Map \
java.util.Set \
java.util.TreeSet \
--module $RECIPE_DIR/pyhelpers \
--reserved INFINITE \
--reserved ERROR \
--reserved OVERFLOW \
--reserved NO_DATA \
--reserved NAN \
--reserved min \
--reserved max \
--reserved mean \
--build \
--install

# Add more build steps here, if they are necessary.


# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
