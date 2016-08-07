%PYTHON% setup.py install --single-version-externally-managed --record record.txt

:: Remove versioned entrypoints.
%PYTHON% -c "import os; print('_'.join(os.environ['PY_VER'].split('.')[0]))" > temp.txt
set /p PY_VER_MAJ=<temp.txt
del temp.txt

del %PREFIX%\Scripts\coverage%PY_VER_MAJ%-script.py
del %PREFIX%\Scripts\coverage%PY_VER_MAJ%.exe
del %PREFIX%\Scripts\coverage%PY_VER_MAJ%.exe.manifest

del %PREFIX%\Scripts\coverage-%PY_VER%-script.py
del %PREFIX%\Scripts\coverage-%PY_VER%.exe
del %PREFIX%\Scripts\coverage-%PY_VER%.exe.manifest

dir /s "%PREFIX%\Scripts\coverage*"
