#!/bin/bash

set -e
set -x

unset TEXMFCNF; export TEXMFCNF
LANG=C; export LANG

# Need the fallback path for testing in some cases.
if [ "$(uname)" == "Darwin" ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

# Using texlive just does not work, various sub-parts ignore that and use PREFIX/share
# SHARE_DIR=${PREFIX}/share/texlive
SHARE_DIR=${PREFIX}/share

declare -a CONFIG_EXTRA
if [[ ${target_platform} =~ .*ppc.* ]]; then
  # luajit is incompatible with powerpc.
  CONFIG_EXTRA+=(--disable-luajittex)
  CONFIG_EXTRA+=(--disable-mfluajit)
fi

TEST_SEGFAULT=no

if [[ ${TEST_SEGFAULT} == yes ]]; then
  # -O2 results in:
  # FAIL: mplibdir/mptraptest.test
  # FAIL: pdftexdir/pdftosrc.test
  # .. so (sorry!)
  export CFLAGS="${CFLAGS} -O0 -ggdb"
  export CXXFLAGS="${CXXFLAGS} -O0 -ggdb"
  CONFIG_EXTRA+=(--enable-debug)
else
  CONFIG_EXTRA+=(--disable-debug)
fi

# kpathsea scans the texmf.cnf file to set up its hardcoded paths, so set them
# up before building. It doesn't seem to handle multivalued TEXMFCNF entries,
# so we patch that up after install.

# mv $SRC_DIR/texk/kpathsea/texmf.cnf tmp.cnf
# sed \
#     -e "s|TEXMFROOT =.*|TEXMFROOT = ${SHARE_DIR}|" \
#     -e "s|TEXMFLOCAL =.*|TEXMFLOCAL = ${SHARE_DIR}/texmf-local|" \
#     -e "/^TEXMFCNF/,/^}/d" \
#     -e "s|%TEXMFCNF =.*|TEXMFCNF = ${SHARE_DIR}/texmf-dist/web2c|" \
#     <tmp.cnf >$SRC_DIR/texk/kpathsea/texmf.cnf
# rm -f tmp.cnf

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

[[ -d "${SHARE_DIR}/tlpkg/TeXLive" ]] || mkdir -p "${SHARE_DIR}/tlpkg/TeXLive"
[[ -d "${SHARE_DIR}/texmf-dist/scripts/texlive" ]] || mkdir -p "${SHARE_DIR}/texmf-dist/scripts/texlive"

cat << EOF >> texlive.profile
selected_scheme medium-scheme
TEXDIR $PREFIX
TEXMFCONFIG $PREFIX/texmf-config
TEXMFHOME $PREFIX/texmf-local
TEXMFLOCAL $PREFIX/texmf-local
TEXMFSYSCONFIG $PREFIX/texmf-config
TEXMFSYSVAR $PREFIX/texmf-var
TEXMFVAR ~/.texlive2015/texmf-var
option_doc 0
option_src 0
EOF


# echo "selected_scheme infra-only
# TEXDIR $PREFIX
# TEXMFLOCAL $PREFIX/texmf-local
# TEXMFSYSVAR $PREFIX/texmf-var
# TEXMFSYSCONFIG $PREFIX/texmf-config
# TEXMFVAR $PREFIX/texmf-var
# TEXMFCONFIG $PREFIX/texmf-config
# TEXMFHOME $PREFIX/texmf-local
# instopt_adjustpath 1
# instopt_adjustrepo 1
# instopt_write18_restricted 1
# tlpdbopt_create_formats 1
# tlpdbopt_desktop_integration 0
# tlpdbopt_file_assocs 1
# tlpdbopt_generate_updmap 0
# tlpdbopt_install_docfiles 0
# tlpdbopt_install_srcfiles 0
# tlpdbopt_post_code 1
# tlpdbopt_sys_bin $PREFIX/bin
# tlpdbopt_sys_info $PREFIX/info
# tlpdbopt_sys_man $PREFIX/man" > texlive-profile


./install-tl -profile texlive.profile
export PATH=$PREFIX/bin/x86_64-linux:$PATH

# # Remove info and man pages.
# rm -rf ${SHARE_DIR}/man
# rm -rf ${SHARE_DIR}/info

# mv ${SHARE_DIR}/texmf-dist/web2c/texmf.cnf tmp.cnf
# sed \
#     -e "s|TEXMFCNF =.*|TEXMFCNF = {${SHARE_DIR}/texmf-local/web2c, ${SHARE_DIR}/texmf-dist/web2c}|" \
#     <tmp.cnf >${SHARE_DIR}/texmf-dist/web2c/texmf.cnf
# rm -f tmp.cnf

# Create symlinks for pdflatex and latex
ln -s $PREFIX/bin/pdftex $PREFIX/bin/pdflatex
ln -s $PREFIX/bin/pdftex $PREFIX/bin/latex
ls $PREFIX/
ls $PREFIX/bin/

tlmgr update --self
# tlmgr install l3build
# tlmgr install latex-bin luahbtex platex uplatex tex xetex
# tlmgr install amsmath tools
# tlmgr install metafont mfware
# tlmgr install bibtex lualatex-math

# tlmgr install babel babel-english latex latex-bin latex-fonts latexconfig xetex

# cd $PREFIX/bin
# # The installer places symlinks to binaries in the $PREFIX/bin folder
# # but also places symlinks for non-existing binaries. These broken symlinks
# # have to be removed to be able to create a working conda package.
# echo "Will remove broken symlinks from the bin folder..."
# find $PREFIX/bin -type l ! -exec test -e {} \; -exec echo "Removing" {} \; -exec rm {} \;
