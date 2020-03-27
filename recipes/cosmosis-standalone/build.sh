export LAPACK_LINK="-llapack ${LDFLGAS}"
export MPIFX=mpifort

export USER_CXXFLAGS=${CXXFLAGS}
export USER_CFLAGS=${CFLAGS}
export USER_FFLAGS=${FFLAGS}

# these should not be packaged
find cosmosis/. -name "*.so" -type f -delete
find cosmosis/. -name "*.o" -type f -delete

# sdist is missing files
cp ${RECIPE_DIR}/handler.c cosmosis/runtime/.

${PYTHON} -m pip install . -vv
