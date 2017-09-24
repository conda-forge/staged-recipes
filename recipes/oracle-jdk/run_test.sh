#!/bin/sh

if [ "${JAVA_HOME}" != "${PREFIX}" ]; then
  echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX})"
  exit 1
fi

pushd test-nio
  javac TestFilePaths.java
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
  java -jar TestFilePaths.jar TestFilePaths.java
popd
