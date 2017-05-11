#!/usr/bin/env bash

export ACE_ROOT=$SRC_DIR

if [ `uname` == Darwin ]; then
    # How do we know what system we are on?
    if [ ${MACOSX_DEPLOYMENT_TARGET} = '10.9' ]; then
        echo "#include \"ace/config-macosx-mavericks.h\"" > ace/config.h
        echo "include \$(ACE_ROOT)/include/makeinclude/platform_macosx_mavericks.GNU" > include/makeinclude/platform_macros.GNU
    elif [ ${MACOSX_DEPLOYMENT_TARGET} = '10.10' ]; then
        echo "#include \"ace/config-macosx-yosemite.h\"" > ace/config.h
        echo "include \$(ACE_ROOT)/include/makeinclude/platform_macosx_yosemite.GNU" > include/makeinclude/platform_macros.GNU
    elif [ ${MACOSX_DEPLOYMENT_TARGET} = '10.11' ]; then
        echo "#include \"ace/config-macosx-elcapitan.h\"" > ace/config.h
        echo "include \$(ACE_ROOT)/include/makeinclude/platform_macosx_elcapitan.GNU" > include/makeinclude/platform_macros.GNU
    fi
fi

if [ `uname` == Linux ]; then
    echo "#include \"ace/config-linux.h\"" > ace/config.h
    echo "include \$(ACE_ROOT)/include/makeinclude/platform_linux.GNU" > include/makeinclude/platform_macros.GNU
fi

make -j $CPU_COUNT -C ace -f GNUmakefile.ACE INSTALL_PREFIX=$PREFIX LDFLAGS="" DESTDIR="" INST_DIR="/ace" debug=0 shared_libs=1 static_libs=1 install

# in future may want to also run the tests, but this would require some work.
# need to have Perl and MPC (https://github.com/DOCGroup/MPC)
# see:  https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/tests/README
