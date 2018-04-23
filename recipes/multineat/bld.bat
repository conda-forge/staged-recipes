@ECHO ON

set MN_BUILD=boost

python %SRC_DIR%/setup.py build_ext
python %SRC_DIR%/setup.py install
