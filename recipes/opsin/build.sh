#!/usr/bin/env bash
set -euxo pipefail

# Install the jar at a path that does not change between versions.
mkdir -p "${PREFIX}/share/opsin" "${PREFIX}/bin"
cp opsin.jar "${PREFIX}/share/opsin/opsin.jar"

# Command wrappers: bash for Linux and macOS, batch for Windows.
cp "${RECIPE_DIR}/opsin" "${PREFIX}/bin/opsin"
chmod 0755 "${PREFIX}/bin/opsin"
cp "${RECIPE_DIR}/opsin.bat" "${PREFIX}/bin/opsin.bat"

# Licence texts that ship inside the jar.
# Each file is byte-identical to the file of the same name in the library's own jar.
extract() {  # extract <path in jar> <target directory>
  mkdir -p "licenses/$2"
  unzip -o -j opsin.jar "$1" -d "licenses/$2"
}
extract META-INF/LICENSE woodstox-core         # woodstox-core 7.1.1
extract META-INF/LICENSE.txt commons-io        # commons-io 2.21.0, full Apache-2.0 text
extract META-INF/NOTICE.txt commons-io         # commons-io 2.21.0
extract META-INF/NOTICE log4j-core             # log4j-core 2.25.3
extract META-INF/AL2.0 jna                     # JNA 5.10.0
extract META-INF/LGPL2.1 jna                   # JNA 5.10.0

# RELAX NG datatype library: licence file from the release archive.
mkdir -p licenses/relaxngDatatype
cp upstream/relaxngDatatype/copying.txt licenses/relaxngDatatype/copying.txt

# ISO RELAX: the MIT licence is in the source file headers; keep the header of one file.
mkdir -p licenses/isorelax
unzip -p upstream/isorelax-sources.jar org/iso_relax/dispatcher/SchemaProvider.java \
  | sed -n '1,/^ \*\//p' > licenses/isorelax/LICENSE-from-source-header.txt
grep -q "Permission is hereby granted" licenses/isorelax/LICENSE-from-source-header.txt

find licenses -type f | sort
