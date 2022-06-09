export IMSUPPORT_DIR=${PREFIX}/imsupport
${PYTHON} -m pip install . -vv

# non-standard layout for the install
mkdir -p ${PREFIX}/pixcorrect/include
cp include/libfixcol.h ${PREFIX}/pixcorrect/include/libfixcol.h

mkdir -p ${PREFIX}/pixcorrect/lib
for nm in "biascorrect" "bpm" "fixcol" "flatcorrect" "masksatr" "fpnumber"; do
  mv ${SP_DIR}/${nm}.*.so ${PREFIX}/pixcorrect/lib/lib${nm}${SHLIB_EXT}
done

# copy the conda ones
for CHANGE in "activate" "deactivate"; do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
  cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
