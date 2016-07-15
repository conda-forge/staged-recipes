"%PYTHON%" setup.py install 

cd "%PREFIX%\share"
mkdir AnyPyToolsTutorial
cd AnyPyToolsTutorial
xcopy "%SRC_DIR%\Tutorial" . /S/Y/I
