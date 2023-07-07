md %PREFIX%\songexplorer
xcopy %SRC_DIR%\* %PREFIX%\songexplorer /S
md %PREFIX%\bin

for %%k in (songexplorer accuracy activations classify cluster compare congruence ensemble ethogram freeze generalize loop misses mistakes time-freq-threshold.py train xvalidate) do (
    echo python %PREFIX%\songexplorer\src\%%~k %%* > %PREFIX%\bin\%%~k.bat
)
echo python %PREFIX%\songexplorer\test\runtests > %PREFIX%\bin\runtests.bat
