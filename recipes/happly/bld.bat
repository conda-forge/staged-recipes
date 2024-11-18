mkdir %PREFIX%\\Library
mkdir %PREFIX%\\Library\\include

cp happly.h %PREFIX%\\Library\\include\\happly.h
if %ERRORLEVEL% neq 0 exit 1
