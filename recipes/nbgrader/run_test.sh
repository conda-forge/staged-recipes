conda install --yes nodejs
# FIXME Hack needed for issue #2117

cd "${SRC_DIR}"
"${PREFIX}/bin/npm install phantomjs-prebuilt
"${PREFIX}/bin/invoke tests --group=python
