cd "${SRC_DIR}"
"${PREFIX}/bin/npm" install .

# On circle-ci, we are building in a container, so CIRCLE_CI is not set
# So this will have to do.
if [ `python -c 'import sys; print(sys.platform)'` == "linux2" ]; then
  npm uninstall phantomjs-prebuilt
  curl --output "${PREFIX}/bin/phantomjs" \
    https://s3.amazonaws.com/circle-downloads/phantomjs-2.1.1
  chmod 755 "${PREFIX}/bin/phantomjs"
fi

"${PREFIX}/bin/npm" run test
