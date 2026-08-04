#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/include/pdf_cpplib/include"
cp -a pdf_cpplib/include/*.hpp "${PREFIX}/include/pdf_cpplib/include/"

mkdir -p "${PREFIX}/lib/pkgconfig"
cat > "${PREFIX}/lib/pkgconfig/pdf_cpplib.pc" <<PC
prefix=${PREFIX}
includedir=\${prefix}/include
Name: pdf_cpplib
Description: C++ probability distribution helpers used by flowy
Version: 0.1.0
Cflags: -I\${includedir}
PC
