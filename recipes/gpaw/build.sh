# customize.py example found at: https://gitlab.com/gpaw/gpaw/blob/master/customize.py
( set -x; python -c "from distutils.sysconfig import get_config_vars as gcv; print(gcv()['BLDLIBRARY']); print(gcv()['INSTSONAME'])" )  # Debugging failed linking against libpython3.6m.a
"%s/%s" % (get_config_var("LIBDIR"), get_config_var("INSTSONAME"))
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
EOF

patch -p1 <<EOF
diff --git a/config.py b/config.py
index d2b89f111..2eeeb42f1 100644
--- a/config.py
+++ b/config.py
@@ -470,8 +470,12 @@ def build_interpreter(define_macros, include_dirs, libraries, library_dirs,
     if glob(libpl + '/libpython*mpi*'):
         libs += ' -lpython%s_mpi' % cfgDict['VERSION']
     else:
-        libs += ' ' + cfgDict.get('BLDLIBRARY',
-                                  '-lpython%s' % cfgDict['VERSION'])
+        pylib = os.path.join([cfgDict[k] for k in 'LIBDIR INSTSONAME'.split()])
+        if os.path.exists(pylib):
+            libs += ' ' + pylib
+        else:
+            libs += ' ' + cfgDict.get('BLDLIBRARY',
+                                      '-lpython%s' % cfgDict['VERSION'])
     libs = ' '.join([libs, cfgDict['LIBS'], cfgDict['LIBM']])
 
     # Hack taken from distutils to determine option for runtime_libary_dirs

EOF

python -m pip install . --no-deps -vv
