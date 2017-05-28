#!/bin/bash

# Compile OOMMF
export OOMMF_TCL_CONFIG=${PREFIX}/lib/tclConfig.sh
export OOMMF_TK_CONFIG=${PREFIX}/lib/tkConfig.sh
cd oommf
tclsh oommf.tcl pimake distclean
tclsh oommf.tcl pimake upgrade
tclsh oommf.tcl pimake
tclsh oommf.tcl +platform

# Copy all OOMMF sources and compiled files into $PREFIX/opt/
install -d ${PREFIX}/opt/
install -d ${PREFIX}/bin/
cp -r ${SRC_DIR}/oommf ${PREFIX}/opt/

# Create an executable called 'oommf' in ${PREFIX}/bin which
# calls the OOMMF executable in $PREFIX/opt/
oommf_command=$(cat <<EOF
#! /bin/bash
export OOMMF_TCL_CONFIG=$PREFIX/lib/tclConfig.sh
export OOMMF_TK_CONFIG=$PREFIX/lib/tkConfig.sh
tclsh $PREFIX/opt/oommf/oommf.tcl "\$@"
EOF
)
echo "$oommf_command" > ${PREFIX}/bin/oommf
chmod a+x ${PREFIX}/bin/oommf
