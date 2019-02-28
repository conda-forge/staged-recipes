#!/usr/bin/env bash

cat > $PREFIX/.messages.txt <<EOF

-------------------------------------------------------------------------------
         conda-forge's singularity $PKG_VERSION POST-LINK INSTRUCTIONS
-------------------------------------------------------------------------------

In order to make use of all singularity features you will need the system
administrator to own and suid the singularity '*-suid' files.

If you have full sudo access, you can do this with the following command:

    sudo find $PREFIX/libexec/singularity \\
        -type f -name '*-suid' \\
        -exec chown root:root {} \; \\
        -exec chmod u+s {} \;

-------------------------------------------------------------------------------
         conda-forge's singularity $PKG_VERSION POST-LINK INSTRUCTIONS
-------------------------------------------------------------------------------
EOF
