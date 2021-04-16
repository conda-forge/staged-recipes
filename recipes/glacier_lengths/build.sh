# The requirements file is (or at least was) not packaged with the tarball, so this has to be recreated.
echo -e "shapely\nnumpy" > requirements.txt
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
