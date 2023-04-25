@REM create folder %LIBRARY_PREFIX%\include\bitmagic
if not exist %LIBRARY_PREFIX%\include\bitmagic mkdir %LIBRARY_PREFIX%\include\bitmagic


@REM copy all files from src to LIBRARY_PREFIX
xcopy /E /I /Y src %LIBRARY_PREFIX%\include\bitmagic
