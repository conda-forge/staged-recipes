xcopy /S "%SRC_DIR%\*.*" "%LIBRARY_PREFIX%"

# Drop the Python-embedded GDB launcher because it hardcodes link to system Python
del %PREFIX%\Library\bin\arm-none-eabi-gdb-py.exe

echo "bat done"
