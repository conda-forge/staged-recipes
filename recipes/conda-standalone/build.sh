# patched conda files
cp conda_src/conda/core/path_actions.py $SP_DIR/conda/core/path_actions.py
cp conda_src/conda/utils.py $SP_DIR/conda/utils.py

# # patched menuinst files - windows only, so ignore these
# cp menuinst_src/menuinst/__init__.py ${SP_DIR}/menuinst/__init__.py
# cp menuinst_src/menuinst/win32.py ${SP_DIR}/menuinst/win32.py

# -F is to create a single file
# -s strips executables and libraries
pyinstaller conda.exe.spec
mkdir -p $PREFIX/standalone_conda
mv dist/conda.exe $PREFIX/standalone_conda
# clean up .pyc files that pyinstaller creates
rm -rf $PREFIX/lib
