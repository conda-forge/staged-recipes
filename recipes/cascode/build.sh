#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"
cp cascode "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/cascode"
