
# On circle-ci, we are building in a container, so CIRCLE_CI is not set
# So this will have to do.
if [ `which yum` ]; then
  yum install fontconfig freetype
fi

cd "${SRC_DIR}"
"${PREFIX}/bin/npm" install .

"${PREFIX}/bin/npm" run test
