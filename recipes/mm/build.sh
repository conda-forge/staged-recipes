# /bin/bash

# sign on
echo "building \"${PKG_NAME}\" \"${PKG_VERSION}\""

# the source layout
src=${SRC_DIR}
src_inc=${src}/include/mm
src_make=${src}/make

# the install layout
prefix=${PREFIX}
prefix_bin=${prefix}/bin
prefix_inc=${prefix}/include/mm
prefix_shr=${prefix}/share/mm

# build the installation layout
mkdir -p ${prefix_bin}
mkdir -p ${prefix_inc}
mkdir -p ${prefix_shr}

# install the main script
cp ${src}/mm.py ${prefix_bin}/mm
# fix its permissions
chmod +x ${prefix_bin}/mm

# copy the headers
# cp -r ${src_inc}/* ${prefix_inc}

# populate the shared area with a copy of the LICENSE
cp ${src}/LICENSE ${prefix_shr}
# the README
cp ${src}/README.md ${prefix_shr}
# and the implementation makefiles
cp -r ${src_make} ${prefix_shr}

# end of file