PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")

# Install python modules
mkdir -p ${PREFIX}/inferno
cp -r inferno/* ${PREFIX}/inferno
echo "${PREFIX}" > ${PREFIX}/lib/python${PY_VER}/site-packages/inferno.pth
python -m compileall ${PREFIX}/inferno
