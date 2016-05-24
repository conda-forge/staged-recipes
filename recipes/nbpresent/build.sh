npm install
npm run build:release
rm -rf node_modules
"${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
"${PREFIX}/bin/jupyter-nbextension" install nbpresent --py --sys-prefix --overwrite
