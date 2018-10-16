mv setup_modified.py setup.py

echo "#include <sys/types.h>" | cat - imagecodecs/imagecodecs.h | tee imagecodecs/imagecodecs.h > /dev/null

export LDSHARED=$CC

#$PYTHON setup.py build_ext --inplace
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
