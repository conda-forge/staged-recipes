CALL %BUILD_PREFIX%\Library\bin\cmake -G "NMake Makefiles" -Bbuild -DCMAKE_BUILD_TYPE:STRING=Release -DOPENBABEL_DIR=%LIBRARY_PREFIX%
CALL cd build
CALL nmake
CALL XCOPY /Y bind* ..\pnab
CALL cd ..
CALL set BABEL_DATADIR="%PREFIX%\share\openbabel"
CALL set SP_DIR="%PREFIX%\Lib\site-packages"
CALL XCOPY /E /I /Y pnab "%SP_DIR%\pnab"
CALL XCOPY /E /I /Y tests "%SP_DIR%\pnab\tests"
CALL XCOPY /Y docs\latex\refman.pdf "%SP_DIR%\pnab"
CALL dir "%SP_DIR%\pnab\"
