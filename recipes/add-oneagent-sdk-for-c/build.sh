#!/bin/env bash

mkdir "${PREFIX}/lib"
cp -a "lib/linux-$(uname -m)/." "${PREFIX}/lib/"
