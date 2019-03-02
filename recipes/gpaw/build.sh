# customize.py example found at: https://gitlab.com/gpaw/gpaw/blob/master/customize.py
cat <<EOF>customize.py
compiler = 'gcc'
mpicompiler = 'mpicc'  # use None if you don't want to build a gpaw-python
mpilinker = 'mpicc'
libraries += ['scalapack-openmpi',
              'blacsCinit-openmpi',
              'blacs-openmpi']
define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
extra_link_args += ['-Wl,-rpath=$PREIFX/lib']
if 'xc' not in libraries:
    libraries.append('xc')
EOF

python -m pip install . --no-deps -vv
