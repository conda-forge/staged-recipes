"%PYTHON%" setup.py install 

cd "%PREFIX%"
mkdir AnyPyToolsTutorial
cd AnyPyToolsTutorial
xcopy "%SRC_DIR%\Tutorial" . /S/Y/I