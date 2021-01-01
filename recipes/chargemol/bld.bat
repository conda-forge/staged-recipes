@echo off

mkdir %PREFIX%\bin

COPY chargemol_FORTRAN_09_26_2017\compiled_binaries\windows\Chargemol_09_26_2017_windows_64bits_parallel_command_line.exe %PREFIX%\bin\chargemol.exe
COPY chargemol_FORTRAN_09_26_2017\compiled_binaries\windows\Chargemol_09_26_2017_windows_64bits_parallel_GUI.exe %PREFIX%\bin\chargemol_gui.exe
COPY chargemol_FORTRAN_09_26_2017\compiled_binaries\windows\pthreadGC2-64.dll %PREFIX%\bin
