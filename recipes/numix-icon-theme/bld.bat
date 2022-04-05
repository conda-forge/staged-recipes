@echo on

:: nothing more to do than copy Numix and Numix-Light to the right location
dir

md "%LIBRARY_PREFIX%\share\icons\Numix"
if errorlevel 1 exit 1

md "%LIBRARY_PREFIX%\share\icons\Numix-Light"
if errorlevel 1 exit 1

(
echo %SRC_DIR%\Numix\128\
echo %SRC_DIR%\Numix\128@2x\
echo %SRC_DIR%\Numix\16@2x\
echo %SRC_DIR%\Numix\22@2x\
echo %SRC_DIR%\Numix\24@2x\
echo %SRC_DIR%\Numix\32@2x\
echo %SRC_DIR%\Numix\48@2x\
echo %SRC_DIR%\Numix\64@2x\
echo %SRC_DIR%\Numix\96\
echo %SRC_DIR%\Numix\96@2x\
)>Exclusion_List_numix.txt

xcopy %SRC_DIR%\Numix /i /f /s /EXCLUDE:Exclusion_List_numix.txt %LIBRARY_PREFIX%\share\icons\Numix\\
if errorlevel 1 exit 1


:: Resolve simbolik links for Numix
md %LIBRARY_PREFIX%\share\icons\Numix\128
md %LIBRARY_PREFIX%\share\icons\Numix\128@2x
md %LIBRARY_PREFIX%\share\icons\Numix\16@2x
md %LIBRARY_PREFIX%\share\icons\Numix\22@2x
md %LIBRARY_PREFIX%\share\icons\Numix\24@2x
md %LIBRARY_PREFIX%\share\icons\Numix\32@2x
md %LIBRARY_PREFIX%\share\icons\Numix\48@2x
md %LIBRARY_PREFIX%\share\icons\Numix\64@2x
md %LIBRARY_PREFIX%\share\icons\Numix\96
md %LIBRARY_PREFIX%\share\icons\Numix\96@2x
if errorlevel 1 exit 1

(
echo %SRC_DIR%\Numix\48\notifications\
)>Exclusion_List_numix_48_to_96.txt

xcopy /i /f /s %SRC_DIR%\Numix\64 %LIBRARY_PREFIX%\share\icons\Numix\128
xcopy /i /f /s %SRC_DIR%\Numix\64 %LIBRARY_PREFIX%\share\icons\Numix\128@2x
xcopy /i /f /s %SRC_DIR%\Numix\16 %LIBRARY_PREFIX%\share\icons\Numix\16@2x
xcopy /i /f /s %SRC_DIR%\Numix\22 %LIBRARY_PREFIX%\share\icons\Numix\22@2x
xcopy /i /f /s %SRC_DIR%\Numix\24 %LIBRARY_PREFIX%\share\icons\Numix\24@2x
xcopy /i /f /s %SRC_DIR%\Numix\32 %LIBRARY_PREFIX%\share\icons\Numix\32@2x
xcopy /i /f /s %SRC_DIR%\Numix\48 %LIBRARY_PREFIX%\share\icons\Numix\48@2x
xcopy /i /f /s %SRC_DIR%\Numix\64 %LIBRARY_PREFIX%\share\icons\Numix\64@2x
xcopy /i /f /s /EXCLUDE:Exclusion_List_numix_48_to_96.txt %SRC_DIR%\Numix\48 %LIBRARY_PREFIX%\share\icons\Numix\96
xcopy /i /f /s %LIBRARY_PREFIX%\share\icons\Numix\96 %LIBRARY_PREFIX%\share\icons\Numix\96@2x
if errorlevel 1 exit 1

(
echo %SRC_DIR%\Numix-Light\16@2x\
echo %SRC_DIR%\Numix-Light\22@2x\
echo %SRC_DIR%\Numix-Light\24@2x\
)>Exclusion_List_numix_light.txt

xcopy %SRC_DIR%\Numix-Light /i /f /s /EXCLUDE:Exclusion_List_numix_light.txt %LIBRARY_PREFIX%\share\icons\Numix-Light\\

if errorlevel 1 exit 1

:: Resolve simbolik links for Numix-Light
md %LIBRARY_PREFIX%\share\icons\Numix-Light\16@2x
md %LIBRARY_PREFIX%\share\icons\Numix-Light\22@2x
md %LIBRARY_PREFIX%\share\icons\Numix-Light\24@2x
if errorlevel 1 exit 1

xcopy %SRC_DIR%\Numix-Light\16 %LIBRARY_PREFIX%\share\icons\Numix-Light\16@2x /S
xcopy %SRC_DIR%\Numix-Light\22 %LIBRARY_PREFIX%\share\icons\Numix-Light\22@2x /S
xcopy %SRC_DIR%\Numix-Light\24 %LIBRARY_PREFIX%\share\icons\Numix-Light\24@2x /S
if errorlevel 1 exit 1
