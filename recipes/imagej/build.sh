#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/{bin,share/imagej}

mvn clean package -Dmaven.compiler.release=8

cp target/ij*.jar ${PREFIX}/share/imagej/ij.jar
install -v -m 0755 ${SRC_DIR}/imagej.sh ${PREFIX}/bin