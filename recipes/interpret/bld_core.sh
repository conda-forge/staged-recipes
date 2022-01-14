chmod +x build.sh
cp -r shared python/interpret-core/symbolic/shared 
cd python/interpret-core
$PYTHON -m pip install -e .
