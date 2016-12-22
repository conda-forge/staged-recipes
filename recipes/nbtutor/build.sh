conda install --yes nodejs
# FIXME: This is an ugly hack. nodejs only gets installed and linked in the
# first build env and doesn't get linked in following build envs

node -v && npm -v

npm install .
npm run build:release
#rm -rf node_modules

"${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
"${PREFIX}/bin/jupyter-nbextension" install --sys-prefix --overwrite --py nbtutor

conda remove --yes nodejs
if (conda list | grep -icq "libgcc")
then
    conda remove --yes libgcc
fi
# Hack again. Remove nodejs and its dep so that build meta_data is happy.
