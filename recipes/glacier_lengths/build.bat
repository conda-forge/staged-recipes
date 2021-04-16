# The requirements file is (or at least was) not packaged with the tarball, so this has to be recreated.
Set-Content .\requirements.txt -Value "shapely`nnumpy"
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
