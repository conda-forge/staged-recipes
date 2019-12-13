REM relies on libode library, creates Python bindings

cd bindings
cd python
python setup.py install --root %PREFIX% --prefix ""
