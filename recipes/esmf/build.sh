export CFLAGS="-Wall -g -m64 -pipe -O2  -fPIC ${CFLAGS}"
export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export ESMF_DIR=`pwd`"/esmf"
export ESMP_source="ESMP"
export ESMF_PTHREADS="OFF"
export ESMF_OS=`uname -s`

export ESMF_COMPILER="gfortran"
export ESMF_ABI="64"
if [ `uname` == Darwin ]; then
    export ESMF_OPENMP="OFF"
    export CC="/usr/bin/gcc"
    export FC=${PREFIX}/bin/gfortran
    export F77=${PREFIX}/bin/gfortran
    export F90=${PREFIX}/bin/gfortran
else
    export ESMF_OPENMP="ON"
fi

# OPENMPI bits
CONDA_LST=`conda list`
if [[ ${CONDA_LST}'y' == *'openmpi'* ]]; then
    export CC=mpicc
    export CXX=mpicxx
    export LC_RPATH="${PREFIX}/lib"
    export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
    # ESMF_COMM env variable, choices are openmpi, mpiuni, mpi, mpich2, or mvapich2
    export ESMF_COMM="openmpi"
else
    export ESMF_COMM="mpiuni"
fi

export ESMF_INSTALL=${PREFIX}
export ESMF_INSTALL_PREFIX=${PREFIX}

export ESMF_MOAB="OFF"
export ESMF_ARRAYLITE="TRUE"
chmod -Rv a+rx esmf/scripts/*
cd esmf
make  -j
make install
cd ../ESMP
export FILES=`find ../../../.. -name "e*.mk" | tail -n1 `
echo "ESMK FILES ${FILES}"
export ESMFMKFILE=`python -c "import sys,os;full = sys.argv[1]; pth2 = os.path.join('libO',full.split('libO')[1][1:]) ; print pth2" ${FILES}`
echo "ESMF_mkfile: ${ESMFMKFILE}"

if [ `uname` == Darwin ]; then
    cat > src/ESMP_Config.py << EOF
    ESMFMKFILE = "libO/Darwin.gfortran.64.mpiuni.default/esmf.mk"
EOF

else
    ${PYTHON} generateESMP_Config.py
fi



cat > ESMP.patch << EOF
--- a/ESMP_LoadESMF.py  2014-01-14 10:00:22.000000000 -0500
+++ b/ESMP_LoadESMF.py  2014-01-14 10:40:57.000000000 -0500
@@ -64,6 +64,13 @@
 #      esmfmk = c[2]

   try:
+
+    # If we are not dealing with an absolute path treat it a relative to the
+    # current Python module.
+    if not os.path.isabs(esmfmk):
+      # Get the directory for this module
+      esmfmk = os.path.abspath(os.path.join(sys.prefix,'lib', esmfmk))
+
     MKFILE = open(esmfmk, 'r')
   except:
     raise IOError("File not found\n  %s") % esmfmk
@@ -72,11 +79,12 @@
   libsdir = 0
   esmfos = 0
   esmfabi = 0
+
+  libsdir = os.path.dirname(esmfmk)
+
 #  MKFILE = open(esmfmk,'r')
   for line in MKFILE:
-    if 'ESMF_LIBSDIR' in line:
-      libsdir = line.split("=")[1]
-    elif 'ESMF_OS:' in line:
+    if 'ESMF_OS:' in line:
       esmfos = line.split(":")[1]
     elif 'ESMF_ABI:' in line:
       esmfabi = line.split(":")[1]
EOF

patch -p1 src/ESMP_LoadESMF.py ESMP.patch
cd ..
cp -rf ESMP ${SP_DIR}

if [ `uname` == Darwin ]; then 
    install_name_tool -id @rpath/libO/Darwin.gfortran.64.mpiuni.default/libesmf_fullylinked.dylib ${PREFIX}/lib/libO/Darwin.gfortran.64.mpiuni.default/libesmf_fullylinked.dylib
    install_name_tool -id @rpath/libO/Darwin.gfortran.64.mpiuni.default/libesmf.dylib ${PREFIX}/lib/libO/Darwin.gfortran.64.mpiuni.default/libesmf.dylib
fi


