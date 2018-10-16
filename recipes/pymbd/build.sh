set -v

mkdir build
(cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX)
make -C build
make -C build install
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
