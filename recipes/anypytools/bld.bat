"%PYTHON%" setup.py install 

cd "%PREFIX%\share"
mkdir notebooks\anypytools
cd notebooks\anypytools
xcopy "%SRC_DIR%\Tutorial" . /S/Y/I
