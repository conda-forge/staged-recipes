set -e -x

#
# For sconsutils.py
#
export PYTHONPATH=external:$PYTHONPATH

#
# Copy compiler flags into these env variables,
# which the scons code recognizes and passes through
#
export DESRES_MODULE_CXXFLAGS=$CXXFLAGS
export DESRES_MODULE_CFLAGS=$CFLAGS
export DESRES_MODULE_LDFLAGS=$LDFLAGS

#
# Conda-forge lpsolve has its headers under 'lpsolve',
# but msys expects them to be in 'lp_solve'.
#
ln -s $PREFIX/include/lpsolve $PREFIX/include/lp_solve


# Multicore build
nprocs=`getconf _NPROCESSORS_ONLN`
scons install -j $nprocs \
    PREFIX=$PREFIX \
    -D MSYS_WITH_INCHI=1 \
    -D MSYS_WITH_LPSOLVE=1 \
    PYTHONVER=$(python -c 'import sys; print("".join(map(str, sys.version_info[:2])))')

#
# By default, msys's scons configuration will install into $PREFIX/lib/python,
# but instead, we want to install into python's site-packages directory.
#

# e.g. lib/python3.5/site-packages
sitepackage_dir=$(python -c 'import os, sys, site; print(os.path.relpath(site.getsitepackages()[0], sys.exec_prefix))')
mv $PREFIX/lib/python/msys $PREFIX/$sitepackage_dir/msys
