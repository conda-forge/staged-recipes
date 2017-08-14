:: LOTS more to do here!

:: This should build the package -- but I couldn't get it to work
:: call "%HOMEPATH%\AppData\Local\Programs\Common\\Microsoft\Visual C++ for Python\9.0\vcvarsall.bat" amd64
:: "%PYTHON%" build-wxpython.py --prefix=$PREFIX --build_dir=../bld  --install

:: This version simply installs the wheels from Chris Gohlke's repo
::   This requires downloading two files -- as far as I can tell, only
::   supported by conda-build 3.*
pip install wxPython_common-3.0.2.0-py2-none-any.whl
pip install wxPython-3.0.2.0-cp27-none-win_amd64.whl

