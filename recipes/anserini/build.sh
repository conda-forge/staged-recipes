#!/bin/bash
set -ex

export MAVEN_OPTS="-Xmx1G"

# first, build remaining code from anserini-tools
cd tools/eval/ndeval && make

cd $SRC_DIR

mvn clean package appassembler:assemble

# copy artefact to PREFIX
ANSERINI_SHARE=$PREFIX/share/anserini
mkdir -p $ANSERINI_SHARE
cp $SRC_DIR/target/anserini-$PKG_VERSION.jar $ANSERINI_SHARE
