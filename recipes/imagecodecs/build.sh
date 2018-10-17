mv setup_modified.py setup.py

mv imagecodecs/imagecodecs.h imagecodecs/imagecodecs.h.old

echo "#include <sys/types.h>" > imagecodecs/imagecodecs.h
cat imagecodecs/imagecodecs.h.old >>  imagecodecs/imagecodecs.h

export LDSHARED=$CC

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
