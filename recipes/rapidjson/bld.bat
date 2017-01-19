set RAPIDJSON_DIR=%SRC_DIR%

REM Copy headers
xcopy /S %RAPIDJSON_DIR%\include %LIBRARY_INC%
