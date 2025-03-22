#!/usr/bin/env bash

mkdir ${PREFIX}/bin

chmod +x ${SRC_DIR}/utilities/*
cp ${SRC_DIR}/utilities/* ${PREFIX}/bin
