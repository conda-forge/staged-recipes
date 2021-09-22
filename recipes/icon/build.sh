#!/bin/env bash

# Abort script upon untested failure
set -e

make Configure name=linux

make CC=${CC}

# Run a small sample of the test suite
make Samples

# Deploy to icon and bin directories at PREFIX
mkdir -p ${PREFIX}/bin
DEPLOY=${PREFIX}/icon

# Install the basics
make Install dest=${DEPLOY}
mv ${DEPLOY}/man ${PREFIX}/man

# Put executables onto the path
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)

# Leave the breadcrumbs required to build loadable C functions
cp ${SRC_DIR}/Makedefs ${DEPLOY}/Makedefs
mkdir -p ${DEPLOY}/ipl/cfuncs; cp    ${SRC_DIR}/ipl/cfuncs/* ${DEPLOY}/ipl/cfuncs/
mkdir -p ${DEPLOY}/ipl/data  ; cp    ${SRC_DIR}/ipl/data/*   ${DEPLOY}/ipl/data/
mkdir -p ${DEPLOY}/ipl/docs  ; cp    ${SRC_DIR}/ipl/docs/*   ${DEPLOY}/ipl/docs/
mkdir -p ${DEPLOY}/ipl/incl  ; cp    ${SRC_DIR}/ipl/incl/*   ${DEPLOY}/ipl/incl/
mkdir -p ${DEPLOY}/ipl/packs ; cp -R ${SRC_DIR}/ipl/packs/*  ${DEPLOY}/ipl/packs
mkdir -p ${DEPLOY}/ipl/procs ; cp    ${SRC_DIR}/ipl/procs/*  ${DEPLOY}/ipl/procs/
mkdir -p ${DEPLOY}/ipl/progs ; cp    ${SRC_DIR}/ipl/progs/*  ${DEPLOY}/ipl/progs/

# Save cfuncs.u? because we have to omit from the build the build tools
#   needed to reconstruct it via ipl/cfuncs/Makefile
cp ${DEPLOY}/lib/cfunc.u? ${DEPLOY}/
# Removing the ucode from lib would reduce the size of the conda package by
#   almost half; the cost of this would be a (slightly) prolonged first activation.
du -sh --apparent-size ${DEPLOY}/lib > ${DEPLOY}/lib/initial_size
rm ${DEPLOY}/lib/*.u?
# However, it apparently is better to increase the size of the package rather
#   than defering this task to the activation; the reason for removing lib/*.u?
#   above is that the default *.u? includes some files (2 Mb out of 4.6 Mb)
#   that are not relevant to this conda pkg.
pushd ${DEPLOY}/ipl/procs
unset LPATH
../../bin/icont -usc *.icn; mv *.u? ../../lib
popd
du -sh --apparent-size ${DEPLOY}/lib > ${DEPLOY}/lib/final_size

# restore cfuncs.u?
mv ${DEPLOY}/cfunc.u? ${DEPLOY}/lib/

# Create instructions to make extension libraries in C
mkdir -p ${DEPLOY}/doc ; cp ${SRC_DIR}/doc/* ${DEPLOY}/doc/
cat > ${DEPLOY}/doc/condagcc.txt << .
#!/bin/env bash

# To build loadable C functions as described at
#   https://www.cs.arizona.edu/icon/uguide/cfuncs.htm
# you will need to add the C compiler and some tools to your environment, e.g.:

    # get the build tools
    conda install -c conda-forge gcc_linux-64 make sed binutils

    # change to the directory with the example
    set -x
    pushd \${CONDA_PREFIX}/icon/ipl/packs/loadfunc

    # build and verify the example
    make CC=\${CC} PROGS='btest ddtest dldemo tnet newsgrp' && ls -l libdemo.so && ./ddtest

    # uncomment to clean up, if desired
    #make clean

    # return to previous directory
    popd

# Bug: Building with C++, e.g.,
#   \${CONDA_PREFIX}/icon/ipl/packs/loadfuncpp
# has not yet been successful in a conda environment.
# It will be necessary but not sufficient to install gxx_linux-64.
.

cat > ${PREFIX}/README_icon << .
    For offline help for icon:
      man icon

    For offline help for icont and iconx:
      man icont

    For info regarding the Icon programming language, please see:
      https://www.cs.arizona.edu/icon

    The Icon Programing Library is at \${IPL}, which points to:
      \${CONDA_PREFIX}/icon/ipl

    This build for '${BUILD}' omits language
    support for graphics; the IPL programs and procedures for
    support of graphics have also been omitted.  For new
    graphical programs, it is probably preferable to use Unicon;
    please see:
      http://unicon.org/

    To build loadable C functions, see:
      \${CONDA_PREFIX}/icon/doc/condagcc.txt
.

# Create or append activation script to set envars and README
mkdir -p ${PREFIX}/etc/conda/activate.d
echo '#!/bin/sh
# set up IPL envar
export IPL_OLD=${IPL}
export IPL=${CONDA_PREFIX}/icon/ipl
' >> ${PREFIX}/etc/conda/activate.d/activate-icon.sh

# Create or append deactivation script to reset IPL envar
mkdir -p ${PREFIX}/etc/conda/deactivate.d
echo '#!/bin/sh
# revert IPL envar
if [ -z "${IPL_OLD}" ]; then
  unset IPL
else
  export IPL=${IPL_OLD}
fi
unset IPL_OLD
' >> ${PREFIX}/etc/conda/deactivate.d/deactivate-icon.sh

