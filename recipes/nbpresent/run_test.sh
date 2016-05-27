cd "${SRC_DIR}"
"${PREFIX}/bin/npm" install .

if [-z "$CIRCLECI"]; then
  npm uninstall phantomjs-prebuilt
  curl --output "${PREFIX}/bin/phantomjs" \
    https://s3.amazonaws.com/circle-downloads/phantomjs-2.1.1
else
  npm install phantomjs-prebuilt
fi

"${PREFIX}/bin/npm" run test
