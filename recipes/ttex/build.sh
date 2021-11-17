#!/bin/bash

echo "selected_scheme scheme-full
TEXDIR $PREFIX" > texlive-profile

./install-tl -profile texlive-profile

cd $PREFIX/bin
# The installer places symlinks to binaries in the $PREFIX/bin folder
# but also places symlinks for non-existing binaries. These broken symlinks
# have to be removed to be able to create a working conda package.
echo "Will remove broken symlinks from the bin folder..."
find $PREFIX/bin -type l ! -exec test -e {} \; -exec echo "Removing" {} \; -exec rm {} \;
