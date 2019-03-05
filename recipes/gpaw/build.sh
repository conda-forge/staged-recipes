# customize.py example found at: https://gitlab.com/gpaw/gpaw/blob/master/customize.py
( set -x; python -c "from distutils.sysconfig import get_config_vars as gcv; print(gcv()['BLDLIBRARY']); print(gcv()['INSTSONAME'])" )  # Debugging failed linking against libpython3.6m.a

cat <<EOF>customize.py
compiler = '${CC}'
mpicompiler = 'mpicc'  # use None if you don't want to build a gpaw-python
mpilinker = 'mpicc'
scalapack = True
fftw = True
libraries += ['scalapack', 'fftw']
              #'scalapack-openmpi',
              #'blacsCinit-openmpi',
              #'blacs-openmpi']
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
extra_link_args += ['-Wl,-rpath=$PREIFX/lib']

if 'xc' not in libraries:
    libraries.append('xc')

for drop in 'lapack blas'.split():
    if drop in libraries:
        libraries.pop(drop)
if not 'openblas' in libraries:
    libraries.append('openblas')


python -m pip install . --no-deps -vv
