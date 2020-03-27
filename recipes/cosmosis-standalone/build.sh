export LAPACK_LINK="-llapack ${LDFLGAS}"
export MPIFX=mpifort

export USER_CXXFLAGS=${CXXFLAGS}
export USER_CFLAGS=${CFLAGS}
export USER_FFLAGS=${FFLAGS}
export USER_LDFLAGS=${LDFLAGS}

export MINUIT2_LIB=${PREFIX}/lib
export MINUIT2_INC=${PREFIX}/include/Minuit2

# need to make sure the setupo can find the source
export COSMOSIS_SRC_DIR=`pwd`/cosmosis

# these should not be packaged :(
find cosmosis/. -name "*.so" -type f -delete
find cosmosis/. -name "*.o" -type f -delete

# sdist is also missing files!
cp ${RECIPE_DIR}/handler.c cosmosis/runtime/.
cp ${RECIPE_DIR}/minuit_wrapper.cpp cosmosis/samplers/minuit/.

${PYTHON} -m pip install . -vv
