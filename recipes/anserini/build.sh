#!/bin/bash

set -ex

export MAVEN_OPTS="-Xmx1G"

# first, build remaining code from anserini-tools
cd tools/eval/ndeval && make

cd $SRC_DIR

mvn clean package appassembler:assemble

mkdir -p ${PREFIX}/lib ${PREFIX}/bin

# TODO: copy correct jar & binaries
# cp ${SRC_DIR}/target/<something>.jar ${PREFIX}/lib/
