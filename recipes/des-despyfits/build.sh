export IMSUPPORT_DIR=${PREFIX}/imsupport
${PYTHON} -m pip install . -vv

# non-standard layout for the install
mkdir -p ${PREFIX}/despyfits/include
mv ${PREFIX}/include/desimage.h ${PREFIX}/despyfits/include/desimage.h
mv ${PREFIX}/include/pixsupport.h ${PREFIX}/despyfits/include/pixsupport.h

mkdir -p ${PREFIX}/despyfits/lib
for nm in "desimage" "maskbits" "compressionhdu"; do
  mv ${SP_DIR}/${nm}.*.so ${PREFIX}/despyfits/lib/lib${nm}${SHLIB_EXT}
done

# copy the conda ones
for CHANGE in "activate" "deactivate"; do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
  cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
