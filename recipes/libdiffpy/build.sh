#!/bin/bash

MYNCPU=$(( (CPU_COUNT > 8) ? 8 : CPU_COUNT ))

# drop linker flags that spuriously remove linkage with libgslcblas
LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs/}"

# Apply sconscript.local customizations.
cp ${RECIPE_DIR}/sconscript.local ./

# Build and install the library.
scons -j $MYNCPU lib install prefix=$PREFIX
