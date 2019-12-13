# relies on libode library, creates Python bindings

# code has aliasing warnings, use flag to prevent crashes 
CFLAGS="-fno-strict-aliasing $CFLAGS"
cd bindings/python
python setup.py install --root "${PREFIX}" --prefix ""
