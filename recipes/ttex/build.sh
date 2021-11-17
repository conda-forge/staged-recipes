#!/bin/bash

echo "selected_scheme scheme-small
TEXDIR $PREFIX
TEXMFLOCAL $PREFIX/texmf-local
TEXMFSYSVAR $PREFIX/texmf-var
TEXMFSYSCONFIG $PREFIX/texmf-config
TEXMFVAR $PREFIX/texmf-var
TEXMFCONFIG $PREFIX/texmf-config
TEXMFHOME $PREFIX/texmf-local
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_write18_restricted 1
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
tlpdbopt_post_code 1
tlpdbopt_sys_bin $PREFIX/bin
tlpdbopt_sys_info $PREFIX/info
tlpdbopt_sys_man $PREFIX/man" > texlive-profile

./install-tl -profile texlive-profile

cd $PREFIX/bin
# The installer places symlinks to binaries in the $PREFIX/bin folder
# but also places symlinks for non-existing binaries. These broken symlinks
# have to be removed to be able to create a working conda package.
echo "Will remove broken symlinks from the bin folder..."
find $PREFIX/bin -type l ! -exec test -e {} \; -exec echo "Removing" {} \; -exec rm {} \;
