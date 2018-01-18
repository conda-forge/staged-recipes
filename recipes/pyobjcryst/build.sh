#!/bin/bash

MYNCPU=$(( (CPU_COUNT > 4) ? 4 : CPU_COUNT ))

# Apply sconscript.local customizations.
# cp ${RECIPE_DIR}/sconscript.local ./

# Install package with scons to utilize multiple CPUs.
scons -j $MYNCPU install prefix=$PREFIX

# Add more build steps here, if they are necessary.

# See http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
