#!/bin/bash
set -e

if [[ `uname` = Darwin ]]; then
    install_name_tool -add_rpath "${PREFIX}/lib" sines
fi

test x"`./sines 0.1+0.01i 0.08+0.001i | ${PREFIX}/bin/harminv 0.05-0.15 | cut -d, -f1-2 | tr '\n' /`" = x"frequency, decay constant/0.08, 1.000000e-03/0.1, 1.000000e-02/"

