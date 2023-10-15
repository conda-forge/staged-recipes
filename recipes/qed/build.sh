# /bin/bash

# sign on
echo "building \"${PKG_NAME}\" \"${PKG_VERSION}\""

# the source layout
src=${SRC_DIR}

# the install layout
prefix=${PREFIX}
prefix_shr=${prefix}/share/qed

# build the installation layout
mkdir -p ${prefix_shr}

# populate the shared area with a copy of the LICENSE
cp ${src}/LICENSE ${prefix_shr}

# end of file