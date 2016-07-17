"%PYTHON%" setup.py install 

cd "%PREFIX%\share"
mkdir notebooks\AnyPyTools
cd notebooks\AnyPyTools
xcopy "%SRC_DIR%\Tutorial" . /S/Y/I

copy "%RECIPE_DIR%\AnyPyToolsTutorial.bat" "%SCRIPTS%\AnyPyToolsTutorial.bat"
