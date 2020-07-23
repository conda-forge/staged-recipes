#!/usr/bin/env bash

# Script inspired by the contents of the sbt debian packages.
# Debian packages: https://dl.bintray.com/sbt/debian/

mkdir -p $PREFIX/share/sbt
mkdir -p $PREFIX/bin

cp -r * $PREFIX/share/sbt

ln -rs $PREFIX/share/sbt/bin/sbt $PREFIX/bin/sbt
ln -rs $PREFIX/share/sbt/bin/java9-rt-export.jar $PREFIX/bin/java9-rt-export.jar

