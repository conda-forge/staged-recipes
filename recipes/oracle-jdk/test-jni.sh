#!/bin/bash

set -e
export 
if [ ! -d $JAVA_LD_LIBRARY_PATH ]; then
	echo "Did you remember to activate the conda environment?"
	exit -1
fi
os=$(uname -s | tr '[:upper:]' '[:lower:]')

gcc \
	-I$JAVA_HOME/include 			\
	-I$JAVA_HOME/include/$os		\
	-Wl,-rpath,$JAVA_LD_LIBRARY_PATH	\
	-L$JAVA_LD_LIBRARY_PATH			\
	-ljvm					\
	-o vmtest				\
	test-jni/vmtest.c 
	
./vmtest
